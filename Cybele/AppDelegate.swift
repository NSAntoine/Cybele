//
//  AppDelegate.swift
//  Cybele
//
//  Created by Serena on 09/07/2023.
//  

import Cocoa
import GameController
import class SwiftUI.NSHostingView

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    let viewItem = NSMenuItem()
    let menu = NSMenu()
    
    static func main() {
        let del = AppDelegate()
        NSApplication.shared.delegate = del
        NSApplication.shared.run()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if Preferences.isFirstTimeLaunch {
            NSApplication.shared.setActivationPolicy(.regular)
            NSApplication.shared.activate(ignoringOtherApps: true)
            
            let controller = WindowController(kind: .welcome)
            controller.showWindow(self)
            controller.window?.makeKey()
        }
        
        if #available(macOS 11.3, *) {
            GCController.shouldMonitorBackgroundEvents = true
        }
        
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem?.button?.image = NSImage(systemSymbolName: "gamecontroller",
                                                 accessibilityDescription: nil)
        
        let hostingView = NSHostingView(rootView: ControllerStatusBarView())
        hostingView.frame = NSRect(x: 0, y: 0, width: 340, height: 300)
        
        viewItem.view = hostingView
        
        menu.addItem(viewItem)
        statusItem.menu = menu
        
        let quitAction = NSMenuItem(title: "Quit", action: #selector(close), keyEquivalent: "q")
        quitAction.keyEquivalentModifierMask = .command
        quitAction.target = self
        menu.addItem(.separator())
        menu.addItem(quitAction)
        
//
//        if !Preferences.isFirstTimeLaunch {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                self.statusItem.button?.performClick(self)
//            }
//        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    
    @objc
    func close() {
        NSApplication.shared.terminate(self)
    }
}
