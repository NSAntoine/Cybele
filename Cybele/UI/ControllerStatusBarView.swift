//
//  ControllerStatusBarView.swift
//  Cybele
//
//  Created by Serena on 10/07/2023.
//

import SwiftUI
import GameController

struct ControllerStatusBarView: View {
    @StateObject var viewModel = ControllerStatusBarViewModel()
    @State var items: [MappableInput] = []
    
    var body: some View {
        switch viewModel.state {
        case .searchingForControllers:
            ProgressView("Waiting for controllers to connect to...")
        case .connected(let controller):
            VStack(spacing: 4) {
                HStack(alignment: .center) {
                    //                    Image(systemName: "gamecontroller")
                    //                        .resizable()
                    //                        .frame(width: 20, height: 20)
                    //                        .padding(.top)
                    //
                    Text("Connected to \(controller.vendorName ?? controller.productCategory)")
                        .font(.title3.bold())
                        .padding(.top)
                }
                
                List(items, id: \.self) { input in
                    MappableInputRowView(controller: controller, input: input)
                }
                .listStyle(.sidebar)
                .onAppear {
                    // set items
                    self.items = MappableInput.allCases.filter { $0.isAvailable(controller: controller) }
                    // set handlers
                    let dict = Preferences.actionsDict
                    for item in items {
                        if let action = dict[item] {
                            item.setHandler(for: controller, handler: action.handler(input:value:isPressed:))
                        }
                    }
                }
            }
        }
    }
}

class ControllerStatusBarViewModel: ObservableObject {
    @Published var state: ModelState = .searchingForControllers
    
    enum ModelState {
        case searchingForControllers
        case connected(GCController)
    }
    
    init() {
        NotificationCenter.default.addObserver(forName: .GCControllerDidBecomeCurrent, object: nil, queue: nil) { [self] notif in
            guard let controller = (notif.object as? GCController) ?? GCController.current else { return }
            self.setState(.connected(controller))
        }
        
        NotificationCenter.default.addObserver(forName: .GCControllerDidStopBeingCurrent, object: nil, queue: nil) { [self] notif in
            self.setState(.searchingForControllers)
        }
    }
    
    func setState(_ newState: ModelState) {
        DispatchQueue.main.async {
            withAnimation {
                self.state = newState
            }
        }
    }
}
