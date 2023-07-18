//
//  Setting.swift
//  Cybele
//
//  Created by Serena on 16/07/2023.
//  

import SwiftUI

struct Setting: View {
    let title: String
    let subtitle: String?
    let imageSystemName: String
    
    let isSelectedItem: Bool
    
    var body: some View {
        mainBody
    }
    
    @ViewBuilder
    var mainBody: some View {
        HStack {
            Circle()
//                .foregroundColor(Color.accentColor)
                .foregroundColor(isSelectedItem ? Color.accentColor : Color(NSColor.secondaryLabelColor))
                .overlay(
                    Image(systemName: imageSystemName)
                        .foregroundColor(.primary)
                )
                .frame(width: 28, height: 28)
                .padding(.leading, 10)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(isSelectedItem ? .title3.bold() : .title3)
                    .foregroundColor(.primary)
                
                if let subtitle {
                    Text(subtitle)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            Spacer()
        }

    }
}
