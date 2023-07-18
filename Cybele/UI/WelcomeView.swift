//
//  WelcomeView.swift
//  Cybele
//
//  Created by Serena on 17/07/2023.
//  

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        mainView
            .frame(width: 300, height: 340)
            .onDisappear {
                Preferences.isFirstTimeLaunch = false
            }
    }
    
    @ViewBuilder
    var mainView: some View {
        VStack(spacing: 0) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
            Text("Welcome to Cybele")
                .font(.largeTitle)
            Text("Created by Serena")
                .foregroundColor(.secondary)
            
            Spacer()
//            HStack {
////                Image(systemName: "questionmark")
////                    .resizable()
////                    .frame(width: 10, height: 20)
////                    .foregroundColor(Color.accentColor)
////                    .padding(.leading, 10)
////
                
            GroupBox {
                Text("Set your binds by tapping the controller button in the menu bar & connecting your game controller.")
//                    .font(.body)
                    .font(.system(size: 13.45))
                    .foregroundColor(.secondary)
            }.padding(.horizontal)
            
//            }
            
            Spacer()
            
            if #available(macOS 12, *) {
                Button("Start", action: closeCurrentWindow)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            } else {
                Button("Start", action: closeCurrentWindow)
                .controlSize(.large)
                .padding(.bottom)
            }
        }
    }
    
    func closeCurrentWindow() {
        NSApplication.shared.setActivationPolicy(.accessory)
        
        for window in NSApplication.shared.windows {
            if window.contentViewController is NSHostingController<WelcomeView> {
                window.close()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            (NSApplication.shared.delegate as? AppDelegate)?.statusItem.button?.performClick(nil)
        }
    }
}
