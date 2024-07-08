import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    private var clipboardChangeCount: Int = 0

    override func applicationDidFinishLaunching(_ notification: Notification) {
        super.applicationDidFinishLaunching(notification)

        clipboardChangeCount = NSPasteboard.general.changeCount

        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkClipboard), userInfo: nil, repeats: true)
    }

    @objc func checkClipboard() {
        if NSPasteboard.general.changeCount != clipboardChangeCount {
            clipboardChangeCount = NSPasteboard.general.changeCount
            if let copiedText = NSPasteboard.general.string(forType: .string) {
                print("Copied text: \(copiedText)") // Terminale yazdır
                sendClipboardChangeNotification(text: copiedText)
            }
        }
    }

    func sendClipboardChangeNotification(text: String) {
        guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else { return }
        let channel = FlutterMethodChannel(name: "clipboard_tracker", binaryMessenger: controller.engine.binaryMessenger)
        channel.invokeMethod("clipboardChanged", arguments: text)
    }
}
