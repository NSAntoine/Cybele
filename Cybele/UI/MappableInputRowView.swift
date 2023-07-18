//
//  MappableInputRowView.swift
//  Cybele
//
//  Created by Serena on 15/07/2023.
//

import SwiftUI
import GameController
import UniformTypeIdentifiers

struct MappableInputRowView: View {
    
    let controller: GCController
    let input: MappableInput
    
    @State var action: Action?
    @State var isExpanded: Bool = false
    @State var actionsListItems: [Action?]
    //    @State var isShowingFileImporter: Bool = false
    
    init(controller: GCController, input: MappableInput) {
        self.controller = controller
        self.input = input
        self.action = Preferences.actionsDict[input]
        self.actionsListItems = [nil] + Action.allCases(isHomeButton: input == .home)
    }
    
    var __isHomeSetToLaunchpad: Bool {
        let dom = UserDefaults(suiteName: "com.apple.GameController")
        return dom?.bool(forKey: "bluetoothPrefsMenuLongPressAction") ?? true
    }
    
    var unmappedText: String {
        // by default,
        // 'home' opens Launchpad
        // this can be changed by setting UserDefault key bluetoothPrefsMenuLongPressAction of com.apple.GameController
        // to 1
        
        if input == .home, __isHomeSetToLaunchpad {
            return "Open Launchpad"
        }
        
        return "(Unmapped)"
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(Color(NSColor.darkGray))
                .frame(height: isExpanded ? CGFloat(48.47 * Double(actionsListItems.count)) : 30)
            mainView
        }
        
//        mainView
//            .background(
//                RoundedRectangle(cornerRadius: 5).foregroundColor(Color(NSColor.darkGray))
//                    .frame(height: isExpanded ? nil : 40)
//                    
//            )
//            
//        RoundedRectangle(cornerRadius: 5)
//            .frame(height: isExpanded ? 100 : 30)
//            .frame(maxHeight: .infinity)
//            .foregroundStyle(Color(NSColor.darkGray))
//            .overlay {
//                
//            }
    }
    
    @ViewBuilder
    var mainView: some View {
        
        VStack {
            HStack {
                let desc = input.descriptions(controller: controller)
                Image(systemName: desc.imageSystemName)
                    .padding(.leading, 10)
                    .foregroundColor(.primary)
                Text(desc.text)
                    .foregroundColor(.primary)
                Spacer()
                
                Text(action?.description ?? unmappedText)
                    .foregroundColor(.gray)
                
                Image(systemName: "chevron.right")
                    .rotationEffect(isExpanded ? .degrees(90) : .zero)
                    .padding(.trailing, 10)
                    .foregroundColor(Color.accentColor)
            }
            .contentShape(Rectangle()) // so that tapping on empty areas works to set isExpanded
            .onTapGesture {
                withAnimation(.spring(bounce: 0.43).speed(1.54)) {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                isExpandedView
            }
        }
    }
    @ViewBuilder
    var isExpandedView: some View {
        Divider()
        
        //                        ScrollView {
        ForEach(actionsListItems, id: \.self) { item in
            ActionRowView(action: item, selectedItem: $action)
        }
        
        .onChange(of: self.action) { newValue in
            if input == .home {
                // if input is home, then disable/enable the launchpad thing
                // from userdefaults, accordingly
                let userDef = UserDefaults(suiteName: "com.apple.GameController")
                
                userDef?.set(newValue == .openLaunchpad, forKey: "bluetoothPrefsMenuLongPressAction")
            }
            
//            let isShowingFileImporter = (newValue == .openFile(nil) || newValue == .playAudio(nil))
            let pickedFile = (newValue == .openFile(nil))
            let pickedAudio = (newValue == .playAudio(nil))
            
            if pickedFile || pickedAudio {
                // fileImporter is buggy here, so we use NSOpenPanel directly instead
                let panel = NSOpenPanel()
                panel.allowedContentTypes = pickedFile ? [.item] : [.audio]
                panel.allowsMultipleSelection = false
                panel.canChooseFiles = true
                panel.canChooseDirectories = true
                
                if panel.runModal() == .OK, let url = panel.url {
                    if newValue == .openFile(nil) {
                        action = .openFile(url.path)
                    } else if newValue == .playAudio(nil) {
                        action = .playAudio(url.path)
                    }
                }
            } else {
                Preferences.actionsDict[input] = newValue
                input.setHandler(for: controller, handler: newValue?.handler(input:value:isPressed:))
            }
        }
    }
}
