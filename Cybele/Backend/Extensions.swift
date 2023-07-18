//
//  Extensions.swift
//  Cybele
//
//  Created by Serena on 17/07/2023.
//  

import Foundation

extension DateFormatter {
    static let mediaFirstPartFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-dd-MM"
        return formatter
    }()
    
    static let mediaSecondPartFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h.mm.ss a"
        return formatter
    }()
}
