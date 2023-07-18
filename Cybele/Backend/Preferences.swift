//
//  Preferences.swift
//  Cybele
//
//  Created by Serena on 15/07/2023.
//  

import Foundation

@propertyWrapper
struct Storage<Value> {
    let key: String
    let fallback: Value
    
    var wrappedValue: Value {
        get {
            (UserDefaults.standard.object(forKey: key) as? Value) ?? fallback
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct CodableStorage<Value: Codable> {
    let key: String
    let fallback: Value
    
    var wrappedValue: Value {
        get {
            guard let data = UserDefaults.standard.data(forKey: key), let decoded = try? JSONDecoder().decode(Value.self, from: data) else {
                return fallback
            }
            
            return decoded
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.setValue(data, forKey: key)
        }
    }
}

enum Preferences {
    
    @Storage(key: "isFirstTimeLaunch", fallback: true)
    static var isFirstTimeLaunch: Bool
    
    @CodableStorage(key: "ActionsDictionary", fallback: [:])
    static var actionsDict: [MappableInput: Action]
}
