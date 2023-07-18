//
//  WindowController.swift
//  Cybele
//
//  Created by Serena on 10/07/2023.
//  

import Cocoa
import class SwiftUI.NSHostingController

class WindowController: NSWindowController {
    enum Kind {
        case screenshot(NSImage, Data)
        case welcome
    }
    
    init(kind: Kind) {
        let vc: NSViewController
        
        switch kind {
        case .screenshot(let nsImage, let data):
            vc = ScreenshotViewController(image: nsImage, imageData: data)
        case .welcome:
            vc = NSHostingController(rootView: WelcomeView())
        }
        
        let window = NSWindow(contentViewController: vc)
        super.init(window: window)
        
        // set window properties
        switch kind {
        case .screenshot:
            window.level = .floating
            window.styleMask.remove(.titled)
            window.setFrame(NSScreen.main!.frame, display: true, animate: true)
            window.backgroundColor = .clear
        case .welcome:
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
            window.backgroundColor = NSColor(name: nil) { appearance in
                switch appearance.name {
                case .aqua, .vibrantLight, .accessibilityHighContrastAqua, .accessibilityHighContrastVibrantLight: // light
                    return .white
                default: // dark
                    return NSColor(red: 0.19, green: 0.19, blue: 0.19, alpha: 1)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
