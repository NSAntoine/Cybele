//
//  Input.swift
//  Cybele
//
//  Created by Serena on 15/07/2023.
//  

import GameController

enum MappableInput: Codable, Hashable, CaseIterable {
    static var allCases: [MappableInput] {
        var cases: [MappableInput] = [.home, .options]
        if #available(macOS 12, *) {
            cases.append(.share)
        }
        
        cases.append(.menu)
        return cases
    }
    
    case home
    case options
    
    @available(macOS 12, *)
    case share
    
    case menu
    
    func setHandler(for controller: GCController, handler: GCControllerButtonValueChangedHandler?) {
        switch self {
        case .home:
            controller.extendedGamepad?.buttonHome?.valueChangedHandler = handler
        case .share:
            if #available(macOS 12, *) {
                let asXbox = controller.extendedGamepad as! GCXboxGamepad
                asXbox.buttonShare?.valueChangedHandler = handler
            }
        case .options:
            controller.extendedGamepad?.buttonOptions?.valueChangedHandler = handler
        case .menu:
            controller.extendedGamepad?.buttonMenu.valueChangedHandler = handler
        }
    }
    
    func isAvailable(controller: GCController) -> Bool {
        switch self {
        // Share is only on Xbox
        case .share:
            return (controller.extendedGamepad as? GCXboxGamepad) != nil
            
        // these are maybe-nil, so check if they return nil or not
        case .home:
            return controller.extendedGamepad?.buttonHome != nil
        case .options:
            return controller.extendedGamepad?.buttonOptions != nil
        default:
            return true
        }
    }
    
    func descriptions(controller: GCController) -> (text: String, imageSystemName: String) {
        lazy var fallbackImageSystemName: String = "questionmark"
        
        switch self {
        case .home:
            return (controller.extendedGamepad?.buttonHome?.unmappedLocalizedName ?? GCInputButtonHome,
                    controller.extendedGamepad?.buttonHome?.unmappedSfSymbolsName ?? fallbackImageSystemName)
        case .share:
            guard #available(macOS 12, *) else { fatalError() /* SHOULD NOT BE HERE. */ }
            
            // the following should always succeed, as, if isAvaileble return false,
            // then it won't reach here.
            let asXbox = controller.extendedGamepad as! GCXboxGamepad
            return (asXbox.buttonShare?.unmappedLocalizedName ?? GCInputButtonShare,
                    asXbox.buttonShare?.unmappedSfSymbolsName ?? fallbackImageSystemName)
        case .options:
            return (controller.extendedGamepad?.buttonOptions?.unmappedLocalizedName ?? GCInputButtonOptions,
                    controller.extendedGamepad?.buttonOptions?.unmappedSfSymbolsName ?? fallbackImageSystemName)
        case .menu:
            return (controller.extendedGamepad?.buttonMenu.unmappedLocalizedName ?? GCInputButtonMenu,
                    controller.extendedGamepad?.buttonMenu.unmappedSfSymbolsName ?? fallbackImageSystemName)
        }
    }
}
