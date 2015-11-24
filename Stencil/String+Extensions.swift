//
//  String+Extensions.swift
//  Spelt
//
//  Created by Niels de Hoog on 24/11/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

extension String {
    func findFirstNot(character: Character) -> String.Index? {
        var index = startIndex
        while index != endIndex {
            if character != self[index] {
                return index
            }
            index = index.successor()
        }
        
        return nil
    }
    
    func findLastNot(character: Character) -> String.Index? {
        var index = endIndex.predecessor()
        while index != startIndex {
            if character != self[index] {
                return index.successor()
            }
            index = index.predecessor()
        }
        
        return nil
    }
    
    func trim(character: Character) -> String {
        guard let first = findFirstNot(character) else {
            return ""
        }
        
        let last = findLastNot(character) ?? endIndex
        return self[first..<last]
    }
    
    var trimQuotationMarks: String {
        return trim("\"").trim("'")
    }
    
    func split(separator: Character, respectQuotes: Bool = false) -> [String] {
        guard respectQuotes == true else {
            return characters.split(separator).map(String.init)
        }
        
        // if respectQuotes is true, leave quoted phrases together
        var word = ""
        var components: [String] = []
        var tempSeparator = separator
        
        for character in characters {
            if character == tempSeparator {
                if character != separator {
                    word.append(character)
                }
                
                if !word.trim(" ").isEmpty {
                    components.append(word)
                    word = ""
                }
                
                tempSeparator = separator
            }
            else {
                if tempSeparator == separator && (character == "'" || character == "\"") {
                    tempSeparator = character
                }
                
                word.append(character)
            }
        }
        
        if !word.isEmpty {
            components.append(word)
        }
        
        return components
    }
    
    func splitAndTrimWhitespace(separator: Character, respectQuotes: Bool = false) -> [String] {
        return split(separator, respectQuotes: respectQuotes).map({ $0.trim(" ") })
    }
}