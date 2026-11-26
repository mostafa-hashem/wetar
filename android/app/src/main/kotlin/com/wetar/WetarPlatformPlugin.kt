package com.wetar

import android.Manifest
import android.app.Activity
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.media.audiofx.BassBoost
import android.media.audiofx.Virtualizer
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.provider.Settings
import android.util.Size
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.Executors

/**
 * Native Android bridge for folder-scoped MediaStore scanning, SAF folder trees,
 * runtime permissions, thumbnail loading, hardware BassBoost/Virtualizer, file pickers,
 * native sharing, battery exemption helpers, and Open-With intent delivery.
 */
class WetarPlatformPlugin(
    private val activity: Activity,
    flutterEngine: FlutterEngine,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "com.wetar/platform",
    )
    private val eventChannel = EventChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "com.wetar/events",
    )

    private val executor = Executors.newFixedThreadPool(2)
    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null
    private var pendingInitialEvent: Map<String, Any?>? = null

    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingPickerResult: MethodChannel.Result? = null
    private var pendingPickerMode: Int = 0
    private var pendingSaveBytes: ByteArray? = null
    private var pendingSaveSourcePath: String? = null

    private var bassBoost: BassBoost? = null
    private var virtualizer: Virtualizer? = null
    private var attachedAudioSessionId: Int = 0

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        pendingInitialEvent?.let { initial ->
            events?.success(initial)
            pendingInitialEvent = null
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun handleIncomingIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action ?: return
        val payload: Map<String, Any?>? = when (action) {
            Intent.ACTION_VIEW -> {
                val uri = intent.data ?: return
                val pathOrTemp = resolveReadableUriToPathOrCopy(uri)
                val parentDir = if (pathOrTemp != null && !pathOrTemp.startsWith(activity.cacheDir.absolutePath)) {
                    File(pathOrTemp).parent
                } else {
                    null
                }
                mapOf(
                    "type" to "open_with",
                    "uri" to uri.toString(),
                    "filePath" to pathOrTemp,
                    "parentFolderPath" to parentDir,
                    "displayName" to queryDisplayName(uri),
                    "mimeType" to (intent.type ?: activity.contentResolver.getType(uri)),
                )
            }
            "com.wetar.SHORTCUT_SHUFFLE" -> mapOf("type" to "shortcut", "target" to "shuffle_all")
            "com.wetar.SHORTCUT_FAVORITES" -> mapOf("type" to "shortcut", "target" to "favorites")
            "com.wetar.SHORTCUT_CAR_MODE" -> mapOf("type" to "shortcut", "target" to "car_mode")
            else -> null
        }
        if (payload != null) {
            emitOrQueueEvent(payload)
        }
    }

    private fun emitOrQueueEvent(event: Map<String, Any?>) {
        mainHandler.post {
            val sink = eventSink
            if (sink != null) {
                sink.success(event)
            } else {
                pendingInitialEvent = event
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkPermissions" -> result.success(currentPermissionsMap())
            "requestPermissions" -> handleRequestPermissions(call, result)
            "openAppSettings" -> {
                val intent = Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.fromParts("package", activity.packageName, null),
                )
                activity.startActivity(intent)
                result.success(true)
            }
            "listAudioFolders" -> {
                executor.execute {
                    try {
                        val folders = queryAudioFolders()
                        mainHandler.post { result.success(folders) }
                    } catch (e: Exception) {
                        mainHandler.post { result.error("FOLDER_QUERY_FAILED", e.message, null) }
                    }
                }
            }
            "scanSelectedFolders" -> {
                @Suppress("UNCHECKED_CAST")
                val args = call.arguments as? Map<String, Any?> ?: emptyMap()
                executor.execute {
                    try {
                        val scanned = scanFolders(args)
                        mainHandler.post { result.success(scanned) }
                    } catch (e: Exception) {
                        mainHandler.post { result.error("SCAN_FAILED", e.message, null) }
                    }
                }
            }
            "loadAlbumArtThumbnail" -> {
                val uriStr = call.argument<String>("uri")
                val filePath = call.argument<String>("filePath")
                val sizePx = call.argument<Int>("sizePx") ?: 256
                val outPath = call.argument<String>("outputPath")
                executor.execute {
                    try {
                        val bytes = extractThumbnailBytes(uriStr, filePath, sizePx)
                        if (bytes != null && outPath != null) {
                            val outFile = File(outPath)
                            outFile.parentFile?.mkdirs()
                            FileOutputStream(outFile).use { it.write(bytes) }
                            mainHandler.post { result.success(outPath) }
                        } else {
                            mainHandler.post { result.success(bytes) }
                        }
                    } catch (_: Exception) {
                        mainHandler.post { result.success(null) }
                    }
                }
            }
            "pickSafFolder" -> launchSafFolderPicker(result)
            "pickFile" -> {
                @Suppress("UNCHECKED_CAST")
                val mimeTypes = call.argument<List<String>>("mimeTypes") ?: listOf("*/*")
                launchFilePicker(mimeTypes, result)
            }
            "saveFile" -> {
                val fileName = call.argument<String>("fileName") ?: "wetar_export"
                val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                val bytes = call.argument<ByteArray>("bytes")
                val sourcePath = call.argument<String>("sourcePath")
                launchSavePicker(fileName, mimeType, bytes, sourcePath, result)
            }
            "shareFiles" -> {
                @Suppress("UNCHECKED_CAST")
                val paths = call.argument<List<String>>("paths") ?: emptyList()
                val mimeType = call.argument<String>("mimeType") ?: "*/*"
                val subject = call.argument<String>("subject")
                shareLocalFiles(paths, mimeType, subject, result)
            }
            "attachAudioEffects" -> {
                val sessionId = call.argument<Int>("audioSessionId") ?: 0
                result.success(attachSessionEffects(sessionId))
            }
            "setBassBoost" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                val strength = call.argument<Int>("strength") ?: 0
                result.success(applyBassBoost(enabled, strength))
            }
            "setVirtualizer" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                val strength = call.argument<Int>("strength") ?: 0
                result.success(applyVirtualizer(enabled, strength))
            }
            "isIgnoringBatteryOptimizations" -> {
                val pm = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
                result.success(pm.isIgnoringBatteryOptimizations(activity.packageName))
            }
            "openBatteryOptimizationSettings" -> {
                val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                activity.startActivity(intent)
                result.success(true)
            }
            "updateHomeWidget" -> {
                val title = call.argument<String>("title")
                val artist = call.argument<String>("artist")
                val artworkPath = call.argument<String>("artworkPath")
                val isPlaying = call.argument<Boolean>("isPlaying") ?: false
                WetarMusicWidgetProvider.updateAll(
                    activity,
                    title,
                    artist,
                    artworkPath,
                    isPlaying,
                )
                result.success(true)
            }
            "setKeepScreenOn" -> {
                val keepOn = call.argument<Boolean>("keepOn") ?: false
                mainHandler.post {
                    if (keepOn) {
                        activity.window.addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    } else {
                        activity.window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun currentPermissionsMap(): Map<String, Boolean> {
        val audioPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }
        val audioGranted = ContextCompat.checkSelfPermission(
            activity,
            audioPermission,
        ) == PackageManager.PERMISSION_GRANTED
        val notificationsGranted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.POST_NOTIFICATIONS,
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
        return mapOf(
            "audio" to audioGranted,
            "notifications" to notificationsGranted,
        )
    }

    private fun handleRequestPermissions(call: MethodCall, result: MethodChannel.Result) {
        if (pendingPermissionResult != null) {
            result.error("PERMISSION_IN_PROGRESS", "Permission request already active", null)
            return
        }
        val includeNotifications = call.argument<Boolean>("includeNotifications") ?: true
        val toRequest = mutableListOf<String>()
        val audioPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }
        if (ContextCompat.checkSelfPermission(activity, audioPermission) != PackageManager.PERMISSION_GRANTED) {
            toRequest.add(audioPermission)
        }
        if (includeNotifications && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(activity, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                toRequest.add(Manifest.permission.POST_NOTIFICATIONS)
            }
        }
        if (toRequest.isEmpty()) {
            result.success(currentPermissionsMap())
            return
        }
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(activity, toRequest.toTypedArray(), REQ_PERMISSIONS)
    }

    fun handlePermissionResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != REQ_PERMISSIONS) return false
        val pending = pendingPermissionResult
        pendingPermissionResult = null
        pending?.success(currentPermissionsMap())
        return true
    }

    private fun queryAudioFolders(): List<Map<String, Any?>> {
        val folders = linkedMapOf<String, MutableFolderAgg>()
        val projection = arrayOf(
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.MIME_TYPE,
        )
        val selection = "${MediaStore.Audio.Media.DURATION} > 0"
        activity.contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            null,
            null,
        )?.use { cursor ->
            val dataCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATA)
            if (dataCol < 0) return emptyList()
            while (cursor.moveToNext()) {
                val path = cursor.getString(dataCol) ?: continue
                val file = File(path)
                val parent = file.parentFile ?: continue
                val parentPath = parent.absolutePath
                val agg = folders.getOrPut(parentPath) {
                    MutableFolderAgg(
                        rootPath = parentPath,
                        displayName = parent.name.ifBlank { parentPath },
                        volumeLabel = inferVolumeLabel(parentPath),
                    )
                }
                agg.trackCount += 1
            }
        }
        return folders.values
            .sortedBy { it.displayName.lowercase() }
            .map {
                mapOf(
                    "rootPath" to it.rootPath,
                    "displayName" to it.displayName,
                    "volumeLabel" to it.volumeLabel,
                    "trackCount" to it.trackCount,
                    "sourceKind" to "mediastore",
                )
            }
    }

    private fun scanFolders(args: Map<String, Any?>): Map<String, Any?> {
        @Suppress("UNCHECKED_CAST")
        val foldersArg = args["folders"] as? List<Map<String, Any?>> ?: emptyList()

        @Suppress("UNCHECKED_CAST")
        val existingByPath = args["existingModified"] as? Map<String, Number> ?: emptyMap()

        val mediaStoreFolders = mutableListOf<FolderRule>()
        val safFolders = mutableListOf<FolderRule>()

        for (raw in foldersArg) {
            val id = (raw["id"] as? Number)?.toInt() ?: continue
            val rootPath = raw["rootPath"] as? String ?: continue
            val sourceKind = raw["sourceKind"] as? String ?: "mediastore"
            val includeSub = raw["includeSubfolders"] as? Boolean ?: true

            @Suppress("UNCHECKED_CAST")
            val excluded = (raw["excludedSubfolders"] as? List<String>) ?: emptyList()
            val rule = FolderRule(
                id = id,
                rootPath = normalizePath(rootPath),
                sourceKind = sourceKind,
                includeSubfolders = includeSub,
                excludedSubfolders = excluded.map { normalizePath(it) },
            )
            if (sourceKind == "saf") {
                safFolders.add(rule)
            } else {
                mediaStoreFolders.add(rule)
            }
        }

        val availableFolderIds = mutableSetOf<Int>()
        for (rule in mediaStoreFolders) {
            if (File(rule.rootPath).exists()) {
                availableFolderIds.add(rule.id)
            }
        }

        val discoveredTracks = mutableListOf<Map<String, Any?>>()
        val activeKeys = mutableListOf<String>()

        if (mediaStoreFolders.isNotEmpty()) {
            val projection = buildList {
                add(MediaStore.Audio.Media._ID)
                add(MediaStore.Audio.Media.DATA)
                add(MediaStore.Audio.Media.TITLE)
                add(MediaStore.Audio.Media.ARTIST)
                add(MediaStore.Audio.Media.ALBUM)
                add(MediaStore.Audio.Media.ALBUM_ID)
                add(MediaStore.Audio.Media.DURATION)
                add(MediaStore.Audio.Media.TRACK)
                add(MediaStore.Audio.Media.YEAR)
                add(MediaStore.Audio.Media.SIZE)
                add(MediaStore.Audio.Media.DATE_MODIFIED)
                add(MediaStore.Audio.Media.DATE_ADDED)
                add(MediaStore.Audio.Media.MIME_TYPE)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    add(MediaStore.Audio.Media.ALBUM_ARTIST)
                    add(MediaStore.Audio.Media.GENRE)
                    add(MediaStore.Audio.Media.BITRATE)
                    add(MediaStore.Audio.Media.CD_TRACK_NUMBER)
                }
            }.toTypedArray()

            activity.contentResolver.query(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                projection,
                "${MediaStore.Audio.Media.DURATION} > 0",
                null,
                null,
            )?.use { cursor ->
                val idCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                val dataCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
                val titleCol = cursor.getColumnIndex(MediaStore.Audio.Media.TITLE)
                val artistCol = cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST)
                val albumCol = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM)
                val albumIdCol = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM_ID)
                val durationCol = cursor.getColumnIndex(MediaStore.Audio.Media.DURATION)
                val trackCol = cursor.getColumnIndex(MediaStore.Audio.Media.TRACK)
                val yearCol = cursor.getColumnIndex(MediaStore.Audio.Media.YEAR)
                val sizeCol = cursor.getColumnIndex(MediaStore.Audio.Media.SIZE)
                val modifiedCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATE_MODIFIED)
                val addedCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATE_ADDED)
                val mimeCol = cursor.getColumnIndex(MediaStore.Audio.Media.MIME_TYPE)
                val albumArtistCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM_ARTIST)
                } else -1
                val genreCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    cursor.getColumnIndex(MediaStore.Audio.Media.GENRE)
                } else -1
                val bitrateCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    cursor.getColumnIndex(MediaStore.Audio.Media.BITRATE)
                } else -1

                while (cursor.moveToNext()) {
                    val filePath = cursor.getString(dataCol) ?: continue
                    val normalizedFile = normalizePath(filePath)
                    val parentFolder = normalizePath(File(normalizedFile).parent ?: continue)
                    val matchedRule = matchBestFolderRule(parentFolder, mediaStoreFolders) ?: continue
                    availableFolderIds.add(matchedRule.id)

                    activeKeys.add(normalizedFile)
                    val modifiedSec = if (modifiedCol >= 0) cursor.getLong(modifiedCol) else 0L
                    val prevModified = existingByPath[normalizedFile]?.toLong()
                    if (prevModified != null && prevModified == modifiedSec) {
                        continue
                    }

                    val mediaId = cursor.getLong(idCol)
                    val contentUri = ContentUris.withAppendedId(
                        MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                        mediaId,
                    ).toString()
                    val albumId = if (albumIdCol >= 0) cursor.getLong(albumIdCol) else 0L
                    val artworkUri = if (albumId > 0L) {
                        ContentUris.withAppendedId(
                            Uri.parse("content://media/external/audio/albumart"),
                            albumId,
                        ).toString()
                    } else null

                    val rawTrack = if (trackCol >= 0) cursor.getInt(trackCol) else 0
                    val discNumber = if (rawTrack >= 1000) rawTrack / 1000 else 1
                    val trackNumber = if (rawTrack >= 1000) rawTrack % 1000 else rawTrack

                    val rawTitle = if (titleCol >= 0) cursor.getString(titleCol) else null
                    val fallbackTitle = File(normalizedFile).nameWithoutExtension
                    discoveredTracks.add(
                        mapOf(
                            "stableKey" to normalizedFile,
                            "folderId" to matchedRule.id,
                            "uri" to contentUri,
                            "filePath" to normalizedFile,
                            "folderPath" to parentFolder,
                            "title" to (rawTitle?.takeIf { it.isNotBlank() } ?: fallbackTitle),
                            "artist" to (if (artistCol >= 0) cursor.getString(artistCol) else null),
                            "album" to (if (albumCol >= 0) cursor.getString(albumCol) else null),
                            "albumArtist" to (if (albumArtistCol >= 0) cursor.getString(albumArtistCol) else null),
                            "genre" to (if (genreCol >= 0) cursor.getString(genreCol) else null),
                            "year" to (if (yearCol >= 0) cursor.getInt(yearCol) else 0),
                            "trackNumber" to trackNumber,
                            "discNumber" to discNumber,
                            "durationMs" to (if (durationCol >= 0) cursor.getLong(durationCol) else 0L),
                            "bitrateKbps" to (if (bitrateCol >= 0) cursor.getInt(bitrateCol) / 1000 else 0),
                            "sampleRateHz" to 0,
                            "channels" to 2,
                            "sizeBytes" to (if (sizeCol >= 0) cursor.getLong(sizeCol) else 0L),
                            "mimeType" to (if (mimeCol >= 0) cursor.getString(mimeCol) else "audio/*"),
                            "dateModifiedSec" to modifiedSec,
                            "dateAddedSec" to (if (addedCol >= 0) cursor.getLong(addedCol) else modifiedSec),
                            "artworkUri" to (artworkUri ?: contentUri),
                        ),
                    )
                }
            }
        }

        for (rule in safFolders) {
            val treeUri = Uri.parse(rule.rootPath)
            val rootDoc = DocumentFile.fromTreeUri(activity, treeUri)
            if (rootDoc == null || !rootDoc.exists() || !rootDoc.canRead()) {
                continue
            }
            availableFolderIds.add(rule.id)
            walkSafTree(
                doc = rootDoc,
                rule = rule,
                relativeSubPath = "",
                existingByPath = existingByPath,
                activeKeys = activeKeys,
                outTracks = discoveredTracks,
            )
        }

        return mapOf(
            "availableFolderIds" to availableFolderIds.toList(),
            "activeStableKeys" to activeKeys,
            "tracks" to discoveredTracks,
        )
    }

    private fun walkSafTree(
        doc: DocumentFile,
        rule: FolderRule,
        relativeSubPath: String,
        existingByPath: Map<String, Number>,
        activeKeys: MutableList<String>,
        outTracks: MutableList<Map<String, Any?>>,
    ) {
        val children = doc.listFiles()
        for (child in children) {
            val childName = child.name ?: continue
            if (childName.startsWith(".")) continue
            if (child.isDirectory) {
                if (!rule.includeSubfolders) continue
                val childRel = if (relativeSubPath.isEmpty()) childName else "$relativeSubPath/$childName"
                if (rule.excludedSubfolders.any { it == childRel || it == child.uri.toString() }) {
                    continue
                }
                walkSafTree(child, rule, childRel, existingByPath, activeKeys, outTracks)
            } else if (child.isFile) {
                val mime = child.type ?: ""
                val ext = childName.substringAfterLast('.', "").lowercase()
                if (!mime.startsWith("audio/") && ext !in AUDIO_EXTENSIONS) continue

                val docUri = child.uri.toString()
                activeKeys.add(docUri)
                val modifiedSec = child.lastModified() / 1000L
                val prevMod = existingByPath[docUri]?.toLong()
                if (prevMod != null && prevMod == modifiedSec) continue

                val meta = readSafMetadata(child.uri, childName)
                outTracks.add(
                    mapOf(
                        "stableKey" to docUri,
                        "folderId" to rule.id,
                        "uri" to docUri,
                        "filePath" to docUri,
                        "folderPath" to rule.rootPath,
                        "title" to (meta.title ?: childName.substringBeforeLast('.')),
                        "artist" to meta.artist,
                        "album" to meta.album,
                        "albumArtist" to meta.albumArtist,
                        "genre" to meta.genre,
                        "year" to meta.year,
                        "trackNumber" to meta.trackNumber,
                        "discNumber" to 1,
                        "durationMs" to meta.durationMs,
                        "bitrateKbps" to meta.bitrateKbps,
                        "sampleRateHz" to meta.sampleRateHz,
                        "channels" to 2,
                        "sizeBytes" to child.length(),
                        "mimeType" to (mime.ifEmpty { "audio/$ext" }),
                        "dateModifiedSec" to modifiedSec,
                        "dateAddedSec" to modifiedSec,
                        "artworkUri" to docUri,
                    ),
                )
            }
        }
    }

    private fun readSafMetadata(uri: Uri, fallbackName: String): SafAudioMeta {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(activity, uri)
            val durationMs = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0L
            val bitrate = (retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)?.toIntOrNull() ?: 0) / 1000
            val year = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_YEAR)?.take(4)?.toIntOrNull() ?: 0
            val trackNo = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER)
                ?.substringBefore('/')?.toIntOrNull() ?: 0
            val sampleRate = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_SAMPLERATE)?.toIntOrNull() ?: 0
            } else 0
            SafAudioMeta(
                title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
                    ?.takeIf { it.isNotBlank() } ?: fallbackName.substringBeforeLast('.'),
                artist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST),
                album = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM),
                albumArtist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST),
                genre = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_GENRE),
                year = year,
                trackNumber = trackNo,
                durationMs = durationMs,
                bitrateKbps = bitrate,
                sampleRateHz = sampleRate,
            )
        } catch (_: Exception) {
            SafAudioMeta(title = fallbackName.substringBeforeLast('.'))
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
            }
        }
    }

    private fun extractThumbnailBytes(uriStr: String?, filePath: String?, sizePx: Int): ByteArray? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && !uriStr.isNullOrBlank()) {
            try {
                val bmp = activity.contentResolver.loadThumbnail(
                    Uri.parse(uriStr),
                    Size(sizePx, sizePx),
                    null,
                )
                return compressBitmap(bmp, sizePx)
            } catch (_: Exception) {
            }
        }

        val retriever = MediaMetadataRetriever()
        try {
            if (!filePath.isNullOrBlank() && !filePath.startsWith("content://")) {
                retriever.setDataSource(filePath)
            } else if (!uriStr.isNullOrBlank()) {
                retriever.setDataSource(activity, Uri.parse(uriStr))
            } else {
                return null
            }
            val embedded = retriever.embeddedPicture ?: return null
            val decoded = BitmapFactory.decodeByteArray(embedded, 0, embedded.size) ?: return null
            return compressBitmap(decoded, sizePx)
        } catch (_: Exception) {
            return null
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
            }
        }
    }

    private fun compressBitmap(bitmap: Bitmap, maxEdge: Int): ByteArray {
        val ratio = minOf(maxEdge.toFloat() / bitmap.width, maxEdge.toFloat() / bitmap.height, 1.0f)
        val scaled = if (ratio < 1.0f) {
            Bitmap.createScaledBitmap(
                bitmap,
                (bitmap.width * ratio).toInt().coerceAtLeast(1),
                (bitmap.height * ratio).toInt().coerceAtLeast(1),
                true,
            )
        } else bitmap
        val out = ByteArrayOutputStream()
        scaled.compress(Bitmap.CompressFormat.JPEG, 84, out)
        if (scaled != bitmap) scaled.recycle()
        bitmap.recycle()
        return out.toByteArray()
    }

    private fun launchSafFolderPicker(result: MethodChannel.Result) {
        if (pendingPickerResult != null) {
            result.error("PICKER_ACTIVE", "Another picker is already open", null)
            return
        }
        pendingPickerResult = result
        pendingPickerMode = REQ_PICK_SAF_FOLDER
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION,
            )
        }
        activity.startActivityForResult(intent, REQ_PICK_SAF_FOLDER)
    }

    private fun launchFilePicker(mimeTypes: List<String>, result: MethodChannel.Result) {
        if (pendingPickerResult != null) {
            result.error("PICKER_ACTIVE", "Another picker is already open", null)
            return
        }
        pendingPickerResult = result
        pendingPickerMode = REQ_PICK_FILE
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = if (mimeTypes.size == 1) mimeTypes.first() else "*/*"
            if (mimeTypes.size > 1) {
                putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes.toTypedArray())
            }
        }
        activity.startActivityForResult(intent, REQ_PICK_FILE)
    }

    private fun launchSavePicker(
        fileName: String,
        mimeType: String,
        bytes: ByteArray?,
        sourcePath: String?,
        result: MethodChannel.Result,
    ) {
        if (pendingPickerResult != null) {
            result.error("PICKER_ACTIVE", "Another picker is already open", null)
            return
        }
        pendingPickerResult = result
        pendingPickerMode = REQ_SAVE_FILE
        pendingSaveBytes = bytes
        pendingSaveSourcePath = sourcePath
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        activity.startActivityForResult(intent, REQ_SAVE_FILE)
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != pendingPickerMode) return false
        val pending = pendingPickerResult
        pendingPickerResult = null
        pendingPickerMode = 0

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            pendingSaveBytes = null
            pendingSaveSourcePath = null
            pending?.success(null)
            return true
        }
        val uri = data.data!!

        when (requestCode) {
            REQ_PICK_SAF_FOLDER -> {
                val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                try {
                    activity.contentResolver.takePersistableUriPermission(uri, flags)
                } catch (_: SecurityException) {
                }
                val doc = DocumentFile.fromTreeUri(activity, uri)
                pending?.success(
                    mapOf(
                        "rootPath" to uri.toString(),
                        "displayName" to (doc?.name ?: uri.lastPathSegment ?: "Folder"),
                        "sourceKind" to "saf",
                    ),
                )
            }
            REQ_PICK_FILE -> {
                executor.execute {
                    val copied = copyUriToImportsCache(uri)
                    mainHandler.post { pending?.success(copied) }
                }
            }
            REQ_SAVE_FILE -> {
                val bytes = pendingSaveBytes
                val sourcePath = pendingSaveSourcePath
                pendingSaveBytes = null
                pendingSaveSourcePath = null
                executor.execute {
                    val ok = try {
                        activity.contentResolver.openOutputStream(uri)?.use { out ->
                            if (bytes != null) {
                                out.write(bytes)
                            } else if (sourcePath != null) {
                                File(sourcePath).inputStream().use { it.copyTo(out) }
                            }
                        }
                        true
                    } catch (_: Exception) {
                        false
                    }
                    mainHandler.post { pending?.success(ok) }
                }
            }
        }
        return true
    }

    private fun shareLocalFiles(
        paths: List<String>,
        mimeType: String,
        subject: String?,
        result: MethodChannel.Result,
    ) {
        if (paths.isEmpty()) {
            result.success(false)
            return
        }
        try {
            val uris = ArrayList(
                paths.map { path ->
                    val file = File(path)
                    FileProvider.getUriForFile(activity, "${activity.packageName}.fileprovider", file)
                },
            )
            val intent = if (uris.size == 1) {
                Intent(Intent.ACTION_SEND).apply {
                    putExtra(Intent.EXTRA_STREAM, uris.first())
                }
            } else {
                Intent(Intent.ACTION_SEND_MULTIPLE).apply {
                    putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris)
                }
            }
            intent.type = mimeType
            if (!subject.isNullOrBlank()) {
                intent.putExtra(Intent.EXTRA_SUBJECT, subject)
            }
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            activity.startActivity(Intent.createChooser(intent, subject))
            result.success(true)
        } catch (e: Exception) {
            result.error("SHARE_FAILED", e.message, null)
        }
    }

    private fun attachSessionEffects(sessionId: Int): Map<String, Any> {
        if (sessionId <= 0) {
            return mapOf("bassBoostSupported" to false, "virtualizerSupported" to false)
        }
        if (attachedAudioSessionId != sessionId) {
            releaseEffects()
            attachedAudioSessionId = sessionId
            try {
                bassBoost = BassBoost(0, sessionId)
            } catch (_: Exception) {
                bassBoost = null
            }
            try {
                virtualizer = Virtualizer(0, sessionId)
            } catch (_: Exception) {
                virtualizer = null
            }
        }
        return mapOf(
            "bassBoostSupported" to (bassBoost?.strengthSupported == true),
            "virtualizerSupported" to (virtualizer?.strengthSupported == true),
        )
    }

    private fun applyBassBoost(enabled: Boolean, strength: Int): Boolean {
        val bb = bassBoost ?: return false
        return try {
            bb.enabled = enabled
            if (bb.strengthSupported) {
                bb.setStrength(strength.coerceIn(0, 1000).toShort())
            }
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun applyVirtualizer(enabled: Boolean, strength: Int): Boolean {
        val v = virtualizer ?: return false
        return try {
            v.enabled = enabled
            if (v.strengthSupported) {
                v.setStrength(strength.coerceIn(0, 1000).toShort())
            }
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun releaseEffects() {
        try {
            bassBoost?.release()
        } catch (_: Exception) {
        }
        try {
            virtualizer?.release()
        } catch (_: Exception) {
        }
        bassBoost = null
        virtualizer = null
    }

    private fun resolveReadableUriToPathOrCopy(uri: Uri): String? {
        if (uri.scheme == "file") return uri.path
        return copyUriToImportsCache(uri)
    }

    private fun copyUriToImportsCache(uri: Uri): String? {
        return try {
            val name = queryDisplayName(uri) ?: "imported_${System.currentTimeMillis()}"
            val safeName = name.replace(Regex("[^A-Za-z0-9._\\-\\u0600-\\u06FF ]"), "_")
            val importsDir = File(activity.cacheDir, "imports").apply { mkdirs() }
            val dest = File(importsDir, "${System.currentTimeMillis()}_$safeName")
            activity.contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(dest).use { output -> input.copyTo(output) }
            }
            dest.absolutePath
        } catch (_: Exception) {
            null
        }
    }

    private fun queryDisplayName(uri: Uri): String? {
        if (uri.scheme == "file") return File(uri.path ?: "").name
        activity.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c ->
            if (c.moveToFirst()) {
                val idx = c.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (idx >= 0) return c.getString(idx)
            }
        }
        return uri.lastPathSegment
    }

    private fun matchBestFolderRule(trackParent: String, rules: List<FolderRule>): FolderRule? {
        var best: FolderRule? = null
        for (rule in rules) {
            val matches = if (rule.includeSubfolders) {
                trackParent == rule.rootPath || trackParent.startsWith("${rule.rootPath}/")
            } else {
                trackParent == rule.rootPath
            }
            if (!matches) continue
            val isExcluded = rule.excludedSubfolders.any { ex ->
                trackParent == ex || trackParent.startsWith("$ex/")
            }
            if (isExcluded) continue
            if (best == null || rule.rootPath.length > best.rootPath.length) {
                best = rule
            }
        }
        return best
    }

    private fun normalizePath(path: String): String =
        if (path.length > 1 && path.endsWith("/")) path.dropLast(1) else path

    private fun inferVolumeLabel(path: String): String =
        if (path.startsWith("/storage/emulated/0")) "Internal Storage"
        else if (path.startsWith("/storage/")) path.removePrefix("/storage/").substringBefore('/')
        else "Device Storage"

    fun dispose() {
        releaseEffects()
        executor.shutdown()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    private data class FolderRule(
        val id: Int,
        val rootPath: String,
        val sourceKind: String,
        val includeSubfolders: Boolean,
        val excludedSubfolders: List<String>,
    )

    private data class MutableFolderAgg(
        val rootPath: String,
        val displayName: String,
        val volumeLabel: String,
        var trackCount: Int = 0,
    )

    private data class SafAudioMeta(
        val title: String? = null,
        val artist: String? = null,
        val album: String? = null,
        val albumArtist: String? = null,
        val genre: String? = null,
        val year: Int = 0,
        val trackNumber: Int = 0,
        val durationMs: Long = 0L,
        val bitrateKbps: Int = 0,
        val sampleRateHz: Int = 0,
    )

    private companion object {
        const val REQ_PERMISSIONS = 4101
        const val REQ_PICK_SAF_FOLDER = 4102
        const val REQ_PICK_FILE = 4103
        const val REQ_SAVE_FILE = 4104
        val AUDIO_EXTENSIONS = setOf("mp3", "m4a", "aac", "flac", "wav", "ogg", "opus", "alac", "aiff", "wma")
    }
}
