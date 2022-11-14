//
//  String.swift
//  SwiftHK
//
//  Created by Lawrence Bensaid on 22/12/2021.
//

import Foundation

extension String {
    
    public struct Characters: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        private init(_ rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let upper: Characters = .init(1)
        public static let lower: Characters = .init(2)
        public static let letters: Characters = [.lower, .upper]
        public static let numbers: Characters = .init(4)
        public static let special: Characters = .init(8)
        public static let symbols: Characters = .init(16)
        public static let uncommon: Characters = [.special, .symbols]
        public static let characters: Characters = [.letters, .numbers, .uncommon]
        public static let spaces: Characters = .init(32)
        public static let tabs: Characters = .init(64)
        public static let linebreak: Characters = .init(128)
        public static let whitespaces: Characters = [.spaces, .tabs, .linebreak]
        
    }
    
    public var isLowercase: Bool {
        guard count > 0 else { return false }
        var lowercase = true
        for character in self {
            if let scala = UnicodeScalar(String(character)) {
                if CharacterSet.uppercaseLetters.contains(scala) {
                    lowercase = false
                }
            }
        }
        return lowercase
    }
    
    public var isUppercase: Bool {
        guard count > 0 else { return false }
        var uppercase = true
        for character in self {
            if let scala = UnicodeScalar(String(character)) {
                if CharacterSet.lowercaseLetters.contains(scala) {
                    uppercase = false
                }
            }
        }
        return uppercase
    }
    
    public static func random(_ characters: Characters, ofSize length: Int) -> String {
        var letters = ""
        if characters.contains(.upper) {
            letters += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        if characters.contains(.lower) {
            letters += "abcdefghijklmnopqrstuvwxyz"
        }
        if characters.contains(.numbers) {
            letters += "0123456789"
        }
        if characters.contains(.special) {
            letters += "!@#$%&?"
        }
        if characters.contains(.symbols) {
            letters += "^*(){}[]_+-=:\"|;'\\<>,./`~§±"
        }
        if characters.contains(.spaces) {
            letters += " "
        }
        if characters.contains(.tabs) {
            letters += "\t"
        }
        if characters.contains(.linebreak) {
            letters += "\n"
        }
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}
