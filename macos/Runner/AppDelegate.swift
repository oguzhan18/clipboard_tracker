

import Cocoa
import FlutterMacOS

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var clipboardChangeCount: Int = 0
    var window: NSWindow?
    var flutterViewController: FlutterViewController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        flutterViewController = FlutterViewController()
        let windowFrame = NSMakeRect(0, 0, 800, 600)
        self.window = NSWindow(
            contentRect: windowFrame,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false)
        self.window?.contentViewController = flutterViewController
        self.window?.setFrame(windowFrame, display: true)
        self.window?.title = "Clipboard Tracker"
        self.window?.makeKeyAndOrderFront(nil)
        
        for window in NSApplication.shared.windows {
            if window != self.window {
                window.close()
            }
        }
        
        clipboardChangeCount = NSPasteboard.general.changeCount
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkClipboard), userInfo: nil, repeats: true)
    }

    @objc func checkClipboard() {
        if NSPasteboard.general.changeCount != clipboardChangeCount {
            clipboardChangeCount = NSPasteboard.general.changeCount
            if let copiedText = NSPasteboard.general.string(forType: .string) {
                print("Copied text: \(copiedText)")
                sendClipboardChangeNotification(text: copiedText)
            }
        }
    }

    func sendClipboardChangeNotification(text: String) {
        let channel = FlutterMethodChannel(name: "clipboard_tracker", binaryMessenger: flutterViewController.engine.binaryMessenger)
        channel.invokeMethod("clipboardChanged", arguments: text)
    }
}


