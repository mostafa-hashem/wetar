import AVFoundation
import Cocoa
import CoreServices
import FlutterMacOS
import UniformTypeIdentifiers

class MainFlutterWindow: NSWindow, NSDraggingDestination {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    var windowFrame = self.frame
    if windowFrame.size.width < 1040 || windowFrame.size.height < 680 {
      windowFrame.size = NSSize(width: 1120, height: 740)
    }
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.center()
    self.minSize = NSSize(width: 840, height: 560)
    self.title = "Wetar"
    self.registerForDraggedTypes([.fileURL])

    RegisterGeneratedPlugins(registry: flutterViewController)
    WetarMacPlugin.shared.attach(window: self, controller: flutterViewController)

    super.awakeFromNib()
  }

  func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    if sender.draggingPasteboard.canReadObject(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) {
      return .copy
    }
    return []
  }

  func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    guard let urls = sender.draggingPasteboard.readObjects(
      forClasses: [NSURL.self],
      options: [.urlReadingFileURLsOnly: true]
    ) as? [URL], !urls.isEmpty else {
      return false
    }
    WetarMacPlugin.shared.handleIncomingURLs(urls)
    return true
  }
}

final class WetarMacPlugin: NSObject, FlutterStreamHandler {
  static let shared = WetarMacPlugin()

  private var methodChannel: FlutterMethodChannel?
  private var eventChannel: FlutterEventChannel?
  private var eventSink: FlutterEventSink?
  private var pendingEvents: [[String: Any]] = []
  private var activeScopedURLs: [String: URL] = [:]
  private var fsEventStream: FSEventStreamRef?
  private var fsDebounceWork: DispatchWorkItem?
  private weak var window: NSWindow?
  private var savedFrame: NSRect?
  private var savedMinSize: NSSize = NSSize(width: 840, height: 560)

  private let supportedAudioExts: Set<String> = [
    "mp3", "mp2", "mp1", "mpga", "mpa",
    "m4a", "m4b", "m4r", "m4p", "aac", "alac", "3ga", "f4a",
    "ogg", "oga", "opus", "spx", "flac", "mka",
    "wav", "wave", "aiff", "aif", "aifc", "caf", "pcm", "au", "snd",
    "wv", "ape", "tta", "tak", "shn", "dsf", "dff", "dsd", "mlp",
    "wma", "amr", "awb", "ac3", "eac3", "ec3", "dts",
    "mid", "midi", "kar", "imy", "ota", "rtttl", "rtx", "xmf", "mxmf",
  ]

  private let videoExts: Set<String> = [
    "mp4", "m4v", "mkv", "webm", "mov", "qt", "avi", "wmv", "flv", "f4v",
    "3gp", "3g2", "3gpp", "3gpp2", "ts", "mts", "m2ts", "vob",
    "mpg", "mpeg", "mpe", "mpv", "m2v", "ogv", "ogm",
    "divx", "xvid", "asf", "rm", "rmvb", "swf", "dv", "amv",
    "h264", "h265", "hevc",
  ]

  func attach(window: NSWindow, controller: FlutterViewController) {
    self.window = window
    let messenger = controller.engine.binaryMessenger

    let mChannel = FlutterMethodChannel(
      name: "com.wetar/platform",
      binaryMessenger: messenger
    )
    mChannel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    self.methodChannel = mChannel

    let eChannel = FlutterEventChannel(
      name: "com.wetar/events",
      binaryMessenger: messenger
    )
    eChannel.setStreamHandler(self)
    self.eventChannel = eChannel
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    for item in pendingEvents {
      events(item)
    }
    pendingEvents.removeAll()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  private func emitEvent(_ payload: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      if let sink = self.eventSink {
        sink(payload)
      } else {
        self.pendingEvents.append(payload)
      }
    }
  }

  func handleIncomingURLs(_ urls: [URL]) {
    for url in urls where url.isFileURL {
      var isDir: ObjCBool = false
      let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
      if exists && isDir.boolValue {
        _ = url.startAccessingSecurityScopedResource()
        let bookmarkBase64 = (try? url.bookmarkData(
          options: [.withSecurityScope],
          includingResourceValuesForKeys: nil,
          relativeTo: nil
        ))?.base64EncodedString()
        if let key = bookmarkBase64 {
          activeScopedURLs[key] = url
        }
        var payload: [String: Any] = [
          "type": "folder_dropped",
          "rootPath": url.path,
          "displayName": url.lastPathComponent,
        ]
        if let key = bookmarkBase64 {
          payload["bookmarkData"] = key
        }
        emitEvent(payload)
      } else {
        let ext = url.pathExtension.lowercased()
        if !videoExts.contains(ext) && supportedAudioExts.contains(ext) {
          _ = url.startAccessingSecurityScopedResource()
          emitEvent([
            "type": "open_with",
            "uri": url.absoluteString,
            "filePath": url.path,
            "parentFolderPath": url.deletingLastPathComponent().path,
            "displayName": url.lastPathComponent,
            "mimeType": "audio/*",
          ])
        }
      }
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]

    switch call.method {
    case "pickFolder":
      pickFolder(result: result)
    case "resolveBookmark":
      let b64 = args["bookmarkData"] as? String ?? ""
      result(resolveBookmark(b64))
    case "stopAccessingBookmark":
      let b64 = args["bookmarkData"] as? String ?? ""
      stopAccessingBookmark(b64)
      result(nil)
    case "watchFolders":
      let paths = args["paths"] as? [String] ?? []
      startWatchingFolders(paths)
      result(nil)
    case "setCompactMiniPlayerMode":
      let compact = args["compact"] as? Bool ?? false
      setCompactMiniPlayerMode(compact)
      result(true)
    case "pickFile":
      pickFile(result: result)
    case "pickGalleryImage":
      pickGalleryImage(result: result)
    case "saveFile":
      let fileName = args["fileName"] as? String ?? "wetar_export"
      let typedBytes = args["bytes"] as? FlutterStandardTypedData
      let sourcePath = args["sourcePath"] as? String
      saveFile(fileName: fileName, bytes: typedBytes?.data, sourcePath: sourcePath, result: result)
    case "shareFiles":
      let paths = args["paths"] as? [String] ?? []
      shareFiles(paths: paths, result: result)
    case "probeAudioFiles":
      let paths = args["paths"] as? [String] ?? []
      probeAudioFiles(paths: paths, result: result)
    case "openAppSettings":
      if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
        NSWorkspace.shared.open(url)
      }
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func pickFolder(result: @escaping FlutterResult) {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        result(nil)
        return
      }
      let panel = NSOpenPanel()
      panel.canChooseFiles = false
      panel.canChooseDirectories = true
      panel.allowsMultipleSelection = false
      panel.canCreateDirectories = false
      panel.prompt = "Select"

      let handleSelection: (NSApplication.ModalResponse) -> Void = { response in
        guard response == .OK, let url = panel.url else {
          result(nil)
          return
        }
        _ = url.startAccessingSecurityScopedResource()
        do {
          let bookmark = try url.bookmarkData(
            options: [.withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
          )
          let b64 = bookmark.base64EncodedString()
          self.activeScopedURLs[b64] = url
          result([
            "rootPath": url.path,
            "displayName": url.lastPathComponent,
            "sourceKind": "bookmark",
            "bookmarkData": b64,
          ])
        } catch {
          result([
            "rootPath": url.path,
            "displayName": url.lastPathComponent,
            "sourceKind": "bookmark",
          ])
        }
      }

      if let win = self.window {
        panel.beginSheetModal(for: win, completionHandler: handleSelection)
      } else {
        handleSelection(panel.runModal())
      }
    }
  }

  private func resolveBookmark(_ bookmarkBase64: String) -> Bool {
    guard let data = Data(base64Encoded: bookmarkBase64) else {
      return false
    }
    var isStale = false
    guard let url = try? URL(
      resolvingBookmarkData: data,
      options: [.withSecurityScope],
      relativeTo: nil,
      bookmarkDataIsStale: &isStale
    ) else {
      return false
    }
    _ = url.startAccessingSecurityScopedResource()
    activeScopedURLs[bookmarkBase64] = url
    return FileManager.default.fileExists(atPath: url.path)
  }

  private func stopAccessingBookmark(_ bookmarkBase64: String) {
    if let url = activeScopedURLs.removeValue(forKey: bookmarkBase64) {
      url.stopAccessingSecurityScopedResource()
    }
  }

  private func startWatchingFolders(_ paths: [String]) {
    stopWatchingFolders()
    let validPaths = paths.filter { FileManager.default.fileExists(atPath: $0) }
    guard !validPaths.isEmpty else { return }

    var context = FSEventStreamContext(
      version: 0,
      info: Unmanaged.passUnretained(self).toOpaque(),
      retain: nil,
      release: nil,
      copyDescription: nil
    )

    let callback: FSEventStreamCallback = { _, clientInfo, numEvents, eventPaths, _, _ in
      guard let clientInfo else { return }
      let plugin = Unmanaged<WetarMacPlugin>.fromOpaque(clientInfo).takeUnretainedValue()
      let cfPaths = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue()
      var firstPath = ""
      if numEvents > 0, let raw = CFArrayGetValueAtIndex(cfPaths, 0) {
        firstPath = Unmanaged<CFString>.fromOpaque(raw).takeUnretainedValue() as String
      }
      plugin.scheduleFolderChangedEvent(firstPath)
    }

    let flags = FSEventStreamCreateFlags(
      kFSEventStreamCreateFlagUseCFTypes |
      kFSEventStreamCreateFlagFileEvents |
      kFSEventStreamCreateFlagNoDefer
    )

    guard let stream = FSEventStreamCreate(
      kCFAllocatorDefault,
      callback,
      &context,
      validPaths as CFArray,
      FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
      0.5,
      flags
    ) else {
      return
    }

    FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)
    FSEventStreamStart(stream)
    self.fsEventStream = stream
  }

  private func stopWatchingFolders() {
    fsDebounceWork?.cancel()
    fsDebounceWork = nil
    if let stream = fsEventStream {
      FSEventStreamStop(stream)
      FSEventStreamInvalidate(stream)
      FSEventStreamRelease(stream)
      fsEventStream = nil
    }
  }

  func scheduleFolderChangedEvent(_ folderPath: String) {
    fsDebounceWork?.cancel()
    let work = DispatchWorkItem { [weak self] in
      self?.emitEvent([
        "type": "folder_changed",
        "folderPath": folderPath,
      ])
    }
    fsDebounceWork = work
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
  }

  private func setCompactMiniPlayerMode(_ compact: Bool) {
    DispatchQueue.main.async { [weak self] in
      guard let self, let win = self.window else { return }
      if compact {
        if self.savedFrame == nil {
          self.savedFrame = win.frame
          self.savedMinSize = win.minSize
        }
        win.minSize = NSSize(width: 360, height: 136)
        win.level = .floating
        let current = win.frame
        let compactHeight: CGFloat = 152
        let nextY = current.maxY - compactHeight
        let target = NSRect(x: current.minX, y: nextY, width: 410, height: compactHeight)
        win.setFrame(target, display: true, animate: true)
      } else {
        win.level = .normal
        win.minSize = self.savedMinSize
        if let restore = self.savedFrame {
          win.setFrame(restore, display: true, animate: true)
        }
        self.savedFrame = nil
      }
    }
  }

  private func pickFile(result: @escaping FlutterResult) {
    DispatchQueue.main.async { [weak self] in
      let panel = NSOpenPanel()
      panel.canChooseFiles = true
      panel.canChooseDirectories = false
      panel.allowsMultipleSelection = false

      let handle: (NSApplication.ModalResponse) -> Void = { response in
        guard response == .OK, let url = panel.url else {
          result(nil)
          return
        }
        result(url.path)
      }

      if let win = self?.window {
        panel.beginSheetModal(for: win, completionHandler: handle)
      } else {
        handle(panel.runModal())
      }
    }
  }

  private func pickGalleryImage(result: @escaping FlutterResult) {
    DispatchQueue.main.async { [weak self] in
      let panel = NSOpenPanel()
      panel.canChooseFiles = true
      panel.canChooseDirectories = false
      panel.allowsMultipleSelection = false
      panel.allowedContentTypes = [.image]
      panel.directoryURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first

      let handle: (NSApplication.ModalResponse) -> Void = { response in
        guard response == .OK, let url = panel.url else {
          result(nil)
          return
        }
        result(url.path)
      }

      if let win = self?.window {
        panel.beginSheetModal(for: win, completionHandler: handle)
      } else {
        handle(panel.runModal())
      }
    }
  }

  private func saveFile(
    fileName: String,
    bytes: Data?,
    sourcePath: String?,
    result: @escaping FlutterResult
  ) {
    DispatchQueue.main.async { [weak self] in
      let panel = NSSavePanel()
      panel.nameFieldStringValue = fileName

      let handle: (NSApplication.ModalResponse) -> Void = { response in
        guard response == .OK, let dest = panel.url else {
          result(false)
          return
        }
        do {
          if let bytes {
            try bytes.write(to: dest, options: .atomic)
            result(true)
          } else if let sourcePath {
            let src = URL(fileURLWithPath: sourcePath)
            if FileManager.default.fileExists(atPath: dest.path) {
              try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: src, to: dest)
            result(true)
          } else {
            result(false)
          }
        } catch {
          result(false)
        }
      }

      if let win = self?.window {
        panel.beginSheetModal(for: win, completionHandler: handle)
      } else {
        handle(panel.runModal())
      }
    }
  }

  private func shareFiles(paths: [String], result: @escaping FlutterResult) {
    DispatchQueue.main.async { [weak self] in
      let urls = paths.compactMap { path -> URL? in
        FileManager.default.fileExists(atPath: path) ? URL(fileURLWithPath: path) : nil
      }
      guard !urls.isEmpty, let view = self?.window?.contentView else {
        result(false)
        return
      }
      let picker = NSSharingServicePicker(items: urls)
      let anchor = NSRect(x: view.bounds.midX - 1, y: view.bounds.midY - 1, width: 2, height: 2)
      picker.show(relativeTo: anchor, of: view, preferredEdge: .minY)
      result(true)
    }
  }

  private func probeAudioFiles(paths: [String], result: @escaping FlutterResult) {
    if paths.isEmpty {
      result([String: [String: Any]]())
      return
    }
    if #available(macOS 13.0, *) {
      Task {
        var out: [String: [String: Any]] = [:]
        for path in paths {
          guard FileManager.default.fileExists(atPath: path) else { continue }
          let asset = AVURLAsset(
            url: URL(fileURLWithPath: path),
            options: [AVURLAssetPreferPreciseDurationAndTimingKey: false]
          )
          var isVideo = false
          if let videoTracks = try? await asset.loadTracks(withMediaType: .video) {
            for track in videoTracks {
              let fps = (try? await track.load(.nominalFrameRate)) ?? 0
              if fps > 1.0 {
                isVideo = true
                break
              }
            }
          }
          var durationMs = 0
          if let cmDuration = try? await asset.load(.duration) {
            let seconds = CMTimeGetSeconds(cmDuration)
            if seconds.isFinite && seconds > 0 {
              durationMs = Int((seconds * 1000.0).rounded())
            }
          }
          var entry: [String: Any] = [
            "isVideo": isVideo,
            "durationMs": durationMs,
          ]
          if !isVideo, let meta = try? await asset.load(.commonMetadata) {
            for item in meta {
              guard let key = item.commonKey else { continue }
              if let val = try? await item.load(.stringValue), !val.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                switch key {
                case .commonKeyTitle:
                  entry["title"] = val.trimmingCharacters(in: .whitespacesAndNewlines)
                case .commonKeyArtist:
                  entry["artist"] = val.trimmingCharacters(in: .whitespacesAndNewlines)
                case .commonKeyAlbumName:
                  entry["album"] = val.trimmingCharacters(in: .whitespacesAndNewlines)
                default:
                  break
                }
              }
            }
          }
          out[path] = entry
        }
        let snapshot = out
        await MainActor.run {
          result(snapshot)
        }
      }
    } else {
      DispatchQueue.global(qos: .userInitiated).async {
        var out: [String: [String: Any]] = [:]
        for path in paths {
          guard FileManager.default.fileExists(atPath: path) else { continue }
          let asset = AVURLAsset(
            url: URL(fileURLWithPath: path),
            options: [AVURLAssetPreferPreciseDurationAndTimingKey: false]
          )
          let semaphore = DispatchSemaphore(value: 0)
          asset.loadValuesAsynchronously(forKeys: ["tracks", "duration", "commonMetadata"]) {
            semaphore.signal()
          }
          _ = semaphore.wait(timeout: .now() + 2.0)

          let isVideo = asset.tracks(withMediaType: .video).contains { $0.nominalFrameRate > 1.0 }
          let seconds = CMTimeGetSeconds(asset.duration)
          let durationMs = (seconds.isFinite && seconds > 0) ? Int((seconds * 1000.0).rounded()) : 0
          var entry: [String: Any] = [
            "isVideo": isVideo,
            "durationMs": durationMs,
          ]
          if !isVideo {
            for item in asset.commonMetadata {
              guard let key = item.commonKey,
                    let val = item.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines),
                    !val.isEmpty else { continue }
              switch key {
              case .commonKeyTitle:
                entry["title"] = val
              case .commonKeyArtist:
                entry["artist"] = val
              case .commonKeyAlbumName:
                entry["album"] = val
              default:
                break
              }
            }
          }
          out[path] = entry
        }
        DispatchQueue.main.async {
          result(out)
        }
      }
    }
  }

  deinit {
    stopWatchingFolders()
    for (_, url) in activeScopedURLs {
      url.stopAccessingSecurityScopedResource()
    }
    activeScopedURLs.removeAll()
  }
}
