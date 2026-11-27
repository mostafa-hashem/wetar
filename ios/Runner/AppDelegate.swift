import AVFoundation
import Flutter
import PhotosUI
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "WetarIosPlugin") {
      WetarIosPlugin.register(with: registrar)
    }
  }
}

final class WetarIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterSceneLifeCycleDelegate, UIDocumentPickerDelegate, PHPickerViewControllerDelegate {
  private enum PickerMode {
    case folder
    case openFile
    case exportFile(URL)
  }

  private var eventSink: FlutterEventSink?
  private var pendingEvents: [[String: Any]] = []
  private var activeScopedURLs: [String: URL] = [:]
  private var pendingResult: FlutterResult?
  private var pickerMode: PickerMode?

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

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = WetarIosPlugin()
    let method = FlutterMethodChannel(
      name: "com.wetar/platform",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: method)

    let events = FlutterEventChannel(
      name: "com.wetar/events",
      binaryMessenger: registrar.messenger()
    )
    events.setStreamHandler(instance)

    registrar.addApplicationDelegate(instance)
    registrar.addSceneDelegate(instance)
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

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    if let contexts = connectionOptions?.urlContexts, !contexts.isEmpty {
      handleOpenURLs(contexts.map(\.url))
      return true
    }
    return false
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    let urls = URLContexts.map(\.url)
    guard !urls.isEmpty else { return false }
    handleOpenURLs(urls)
    return true
  }

  func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    handleOpenURLs([url])
    return true
  }

  private func handleOpenURLs(_ urls: [URL]) {
    for url in urls where url.isFileURL {
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

  private func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let keyWindow = scenes
      .flatMap(\.windows)
      .first(where: \.isKeyWindow) ?? scenes.flatMap(\.windows).first
    var top = keyWindow?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]

    switch call.method {
    case "pickFolder":
      presentFolderPicker(result: result)
    case "resolveBookmark":
      let b64 = args["bookmarkData"] as? String ?? ""
      result(resolveBookmark(b64))
    case "stopAccessingBookmark":
      let b64 = args["bookmarkData"] as? String ?? ""
      stopAccessingBookmark(b64)
      result(nil)
    case "triggerCloudDownload":
      let filePath = args["filePath"] as? String ?? ""
      result(triggerCloudDownload(filePath))
    case "pickFile":
      presentFilePicker(result: result)
    case "pickGalleryImage":
      presentGalleryPicker(result: result)
    case "saveFile":
      let fileName = args["fileName"] as? String ?? "wetar_export"
      let typedBytes = args["bytes"] as? FlutterStandardTypedData
      let sourcePath = args["sourcePath"] as? String
      presentExportPicker(fileName: fileName, bytes: typedBytes?.data, sourcePath: sourcePath, result: result)
    case "shareFiles":
      let paths = args["paths"] as? [String] ?? []
      presentShareSheet(paths: paths, result: result)
    case "probeAudioFiles":
      let paths = args["paths"] as? [String] ?? []
      probeAudioFiles(paths: paths, result: result)
    case "openAppSettings":
      DispatchQueue.main.async {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        result(true)
      }
    case "setKeepScreenOn":
      let keepOn = args["keepOn"] as? Bool ?? false
      DispatchQueue.main.async {
        UIApplication.shared.isIdleTimerDisabled = keepOn
        result(true)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func presentFolderPicker(result: @escaping FlutterResult) {
    DispatchQueue.main.async { [weak self] in
      guard let self, let presenter = self.topViewController() else {
        result(nil)
        return
      }
      self.pendingResult = result
      self.pickerMode = .folder
      let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
      picker.allowsMultipleSelection = false
      picker.delegate = self
      presenter.present(picker, animated: true)
    }
  }

  private func presentFilePicker(result: @escaping FlutterResult) {
    DispatchQueue.main.async { [weak self] in
      guard let self, let presenter = self.topViewController() else {
        result(nil)
        return
      }
      self.pendingResult = result
      self.pickerMode = .openFile
      let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
      picker.allowsMultipleSelection = false
      picker.delegate = self
      presenter.present(picker, animated: true)
    }
  }

  private func presentGalleryPicker(result: @escaping FlutterResult) {
    DispatchQueue.main.async { [weak self] in
      guard let self, let presenter = self.topViewController() else {
        result(nil)
        return
      }
      self.pendingResult = result
      var config = PHPickerConfiguration(photoLibrary: .shared())
      config.selectionLimit = 1
      config.filter = .images
      let picker = PHPickerViewController(configuration: config)
      picker.delegate = self
      presenter.present(picker, animated: true)
    }
  }

  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    let cb = pendingResult
    pendingResult = nil
    guard let cb else { return }
    guard let provider = results.first?.itemProvider,
          provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else {
      cb(nil)
      return
    }
    provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
      guard let data else {
        DispatchQueue.main.async { cb(nil) }
        return
      }
      let outURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("wetar_gallery_\(Int(Date().timeIntervalSince1970 * 1000)).jpg")
      do {
        try data.write(to: outURL, options: .atomic)
        DispatchQueue.main.async { cb(outURL.path) }
      } catch {
        DispatchQueue.main.async { cb(nil) }
      }
    }
  }

  private func presentExportPicker(
    fileName: String,
    bytes: Data?,
    sourcePath: String?,
    result: @escaping FlutterResult
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self, let presenter = self.topViewController() else {
        result(false)
        return
      }
      let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
      do {
        if FileManager.default.fileExists(atPath: tempURL.path) {
          try FileManager.default.removeItem(at: tempURL)
        }
        if let bytes {
          try bytes.write(to: tempURL, options: .atomic)
        } else if let sourcePath {
          try FileManager.default.copyItem(at: URL(fileURLWithPath: sourcePath), to: tempURL)
        } else {
          result(false)
          return
        }
      } catch {
        result(false)
        return
      }

      self.pendingResult = result
      self.pickerMode = .exportFile(tempURL)
      let picker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: true)
      picker.delegate = self
      presenter.present(picker, animated: true)
    }
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    let cb = pendingResult
    let mode = pickerMode
    pendingResult = nil
    pickerMode = nil

    guard let cb, let mode else { return }

    switch mode {
    case .folder:
      guard let url = urls.first else {
        cb(nil)
        return
      }
      let scoped = url.startAccessingSecurityScopedResource()
      if let bookmark = try? url.bookmarkData(
        options: [],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      ) {
        let b64 = bookmark.base64EncodedString()
        if scoped {
          activeScopedURLs[b64] = url
        }
        cb([
          "rootPath": url.path,
          "displayName": url.lastPathComponent,
          "sourceKind": "bookmark",
          "bookmarkData": b64,
        ])
      } else {
        cb([
          "rootPath": url.path,
          "displayName": url.lastPathComponent,
          "sourceKind": "documents",
        ])
      }
    case .openFile:
      cb(urls.first?.path)
    case .exportFile(let tempURL):
      cb(!urls.isEmpty)
      cleanupTempURL(tempURL)
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    let cb = pendingResult
    let mode = pickerMode
    pendingResult = nil
    pickerMode = nil

    guard let cb, let mode else { return }
    switch mode {
    case .folder, .openFile:
      cb(nil)
    case .exportFile(let tempURL):
      cb(false)
      cleanupTempURL(tempURL)
    }
  }

  private func cleanupTempURL(_ url: URL) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      try? FileManager.default.removeItem(at: url)
    }
  }

  private func resolveBookmark(_ bookmarkBase64: String) -> Bool {
    guard !bookmarkBase64.isEmpty, let data = Data(base64Encoded: bookmarkBase64) else {
      return false
    }
    var isStale = false
    guard let url = try? URL(
      resolvingBookmarkData: data,
      options: [.withoutUI],
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

  private func triggerCloudDownload(_ filePath: String) -> Bool {
    guard !filePath.isEmpty else { return false }
    let directURL = URL(fileURLWithPath: filePath)
    do {
      try FileManager.default.startDownloadingUbiquitousItem(at: directURL)
      return true
    } catch {
      let last = directURL.lastPathComponent
      if !last.hasPrefix(".") {
        let placeholder = directURL
          .deletingLastPathComponent()
          .appendingPathComponent(".\(last).icloud")
        if let _ = try? FileManager.default.startDownloadingUbiquitousItem(at: placeholder) {
          return true
        }
      }
      return false
    }
  }

  private func presentShareSheet(paths: [String], result: @escaping FlutterResult) {
    DispatchQueue.main.async { [weak self] in
      let urls = paths.compactMap { path -> URL? in
        FileManager.default.fileExists(atPath: path) ? URL(fileURLWithPath: path) : nil
      }
      guard !urls.isEmpty, let presenter = self?.topViewController() else {
        result(false)
        return
      }
      let activity = UIActivityViewController(activityItems: urls, applicationActivities: nil)
      if let pop = activity.popoverPresentationController {
        pop.sourceView = presenter.view
        pop.sourceRect = CGRect(
          x: presenter.view.bounds.midX,
          y: presenter.view.bounds.midY,
          width: 1,
          height: 1
        )
        pop.permittedArrowDirections = []
      }
      presenter.present(activity, animated: true)
      result(true)
    }
  }

  private func probeAudioFiles(paths: [String], result: @escaping FlutterResult) {
    if paths.isEmpty {
      result([String: [String: Any]]())
      return
    }
    if #available(iOS 16.0, *) {
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
    for (_, url) in activeScopedURLs {
      url.stopAccessingSecurityScopedResource()
    }
    activeScopedURLs.removeAll()
  }
}
