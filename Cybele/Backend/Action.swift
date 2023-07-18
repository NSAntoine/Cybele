//
//  Action.swift
//  Cybele
//
//  Created by Serena on 15/07/2023.
//  

import Cocoa
import GameController

enum Action: Codable, Hashable, CustomStringConvertible/*, CaseIterable*/ {
    static func allCases(isHomeButton: Bool) -> [Action] {
        var cases: [Action] = [.screenshot, .recordScreen, .playAudio(nil), .openFile(nil),]
        if isHomeButton {
            cases.append(.openLaunchpad)
        }
        return cases
    }
    
    static var _currentAudioPlayer: NSSound? = nil
    static var _audioPlayerPlaying: Bool = false
    
    static var _screenRecorder: ScreenRecorder? = nil
    
    case screenshot
    case recordScreen
    case openFile(String? /* = path */)
    case playAudio(String? /* =path */)
    case openLaunchpad
    
    func handler(input: GCControllerButtonInput, value: Float, isPressed: Bool) {
        guard isPressed else { return }
        
        switch self {
        case .screenshot:
            
            let mainDisplayID = CGMainDisplayID()
            guard let image = CGDisplayCreateImage(mainDisplayID) else {
                return
            }
            
            let bitmapRep = NSBitmapImageRep(cgImage: image)
            let jpegData = bitmapRep.representation(using: .png, properties: [:])!
            
            if let img = NSImage(data: jpegData) {
                WindowController(kind: .screenshot(img, jpegData)).showWindow(self)
            }
            
            // play capture sound
            let screenCaptureSoundPath = "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Screen Capture.aif"
            if let sound = NSSound(contentsOf: URL(fileURLWithPath: screenCaptureSoundPath), byReference: false) {
                sound.play()
            }
            
        case .recordScreen:
            Task {
                do {
                    if Self._screenRecorder != nil {
                        Self._screenRecorder = nil
                        return
                    }
                    
                    Self._screenRecorder = try await ScreenRecorder()
                    try await Self._screenRecorder?.start()
                } catch {
                    print(error) // todo: handle this better (I really hate just doing print(error) :/)
                }
            }
        case .openFile(let path):
            guard let path else { return }
            let url = URL(fileURLWithPath: path)
            
            if url.pathExtension == "app" {
                NSWorkspace.shared.openApplication(at: url, configuration: .init())
            } else {
                NSWorkspace.shared.open(url)
            }
            
        case .playAudio(let path):
            if let current = Self._currentAudioPlayer {
                
                _ = Self._audioPlayerPlaying ? current.pause() : current.resume()
                Self._audioPlayerPlaying.toggle()
                return
            }
            
            guard let path, let sound = NSSound(contentsOf: URL(fileURLWithPath: path), byReference: false) else { return }
            Self._currentAudioPlayer = sound
            sound.play()
            Self._audioPlayerPlaying = true
            
        case .openLaunchpad:
            break // don't do anything, this is handled by the System
        }
    }
    
    var description: String {
        switch self {
        case .screenshot:
            return "Screenshot"
        case .recordScreen:
            return "Record Screen"
        case .openFile:
            return "Open File/Application"
        case .playAudio:
            return "Play Audio"
        case .openLaunchpad:
            return "Open Launchpad"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .playAudio:
            return "Pause/Resume by pressing the button."
        case .recordScreen:
            return "Stop recording screen by pressing the button."
        default:
            return nil
        }
    }
    
    var systemImageName: String {
        switch self {
        case .screenshot:
            return "camera"
        case .recordScreen:
            return "record.circle"
        case .openFile:
            return "folder"
        case .playAudio:
            return "waveform.path"
        case .openLaunchpad:
            return "apps.iphone"
        }
    }
}
