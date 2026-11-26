package com.yourname.wetar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.view.KeyEvent
import android.widget.RemoteViews
import com.ryanheise.audioservice.MediaButtonReceiver
import java.io.File

/**
 * Lightweight Android home screen widget updated directly by WetarAudioHandler
 * on track or playback-state changes (zero background polling).
 */
class WetarMusicWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val title = prefs.getString("title", "Wetar") ?: "Wetar"
        val artist = prefs.getString("artist", "Offline Music") ?: "Offline Music"
        val artworkPath = prefs.getString("artworkPath", null)
        val isPlaying = prefs.getBoolean("isPlaying", false)

        for (widgetId in appWidgetIds) {
            val views = buildViews(context, title, artist, artworkPath, isPlaying)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    companion object {
        private const val PREFS_NAME = "wetar_widget_cache"

        fun updateAll(
            context: Context,
            title: String?,
            artist: String?,
            artworkPath: String?,
            isPlaying: Boolean,
        ) {
            val safeTitle = title?.takeIf { it.isNotBlank() } ?: "Wetar"
            val safeArtist = artist?.takeIf { it.isNotBlank() } ?: "Offline Music"
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
                .putString("title", safeTitle)
                .putString("artist", safeArtist)
                .putString("artworkPath", artworkPath)
                .putBoolean("isPlaying", isPlaying)
                .apply()

            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, WetarMusicWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            if (ids.isEmpty()) return

            val views = buildViews(context, safeTitle, safeArtist, artworkPath, isPlaying)
            for (id in ids) {
                manager.updateAppWidget(id, views)
            }
        }

        private fun buildViews(
            context: Context,
            title: String,
            artist: String,
            artworkPath: String?,
            isPlaying: Boolean,
        ): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.wetar_widget)
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_artist, artist)
            views.setImageViewResource(
                R.id.widget_play_pause,
                if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play,
            )

            if (!artworkPath.isNullOrBlank() && File(artworkPath).exists()) {
                val bmp = BitmapFactory.decodeFile(artworkPath)
                if (bmp != null) {
                    views.setImageViewBitmap(R.id.widget_artwork, bmp)
                }
            } else {
                views.setImageViewResource(R.id.widget_artwork, R.mipmap.ic_launcher)
            }

            val launchIntent = Intent(context, MainActivity::class.java)
            val launchPending = PendingIntent.getActivity(
                context,
                10,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.wetar_widget_root, launchPending)

            views.setOnClickPendingIntent(
                R.id.widget_prev,
                mediaKeyPendingIntent(context, 11, KeyEvent.KEYCODE_MEDIA_PREVIOUS),
            )
            views.setOnClickPendingIntent(
                R.id.widget_play_pause,
                mediaKeyPendingIntent(context, 12, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE),
            )
            views.setOnClickPendingIntent(
                R.id.widget_next,
                mediaKeyPendingIntent(context, 13, KeyEvent.KEYCODE_MEDIA_NEXT),
            )
            return views
        }

        private fun mediaKeyPendingIntent(
            context: Context,
            requestCode: Int,
            keyCode: Int,
        ): PendingIntent {
            val intent = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
                component = ComponentName(context, MediaButtonReceiver::class.java)
                putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
            }
            return PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}
