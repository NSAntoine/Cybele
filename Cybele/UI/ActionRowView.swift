//
//  ActionRowView.swift
//  Cybele
//
//  Created by Serena on 15/07/2023.
//  

import SwiftUI

struct ActionRowView: View {
    let action: Action?
    
    @Binding var selectedItem: Action?
    
    var body: some View {
        Button {
            selectedItem = action
        } label: {
            Setting(title: action?.description ?? "None",
                    subtitle: action?.subtitle,
                    imageSystemName: action?.systemImageName ?? "xmark",
                    isSelectedItem: (selectedItem == action))
        }
        .buttonStyle(.plain)
    }
}

