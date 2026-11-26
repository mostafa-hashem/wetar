import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func application(_ sender: NSApplication, open urls: [URL]) {
    WetarMacPlugin.shared.handleIncomingURLs(urls)
  }

  override func application(_ sender: NSApplication, openFiles filenames: [String]) {
    let urls = filenames.map { URL(fileURLWithPath: $0) }
    WetarMacPlugin.shared.handleIncomingURLs(urls)
    sender.reply(toOpenOrPrint: .success)
  }
}
