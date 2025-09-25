//
//  Allergens.swift
//  Yes Chef
//
//  Created by Neel Bhattacharyya on 9/18/25.
//

import Foundation

enum Allergen: String, Codable, CaseIterable {
    case eggs = "Eggs"
    case soy = "Soy"
    case sesame = "Sesame"
    case dairy = "Dairy"
    case nuts = "Nuts"
    case fish = "Fish"
    case shellfish = "Shellfish"
    case gluten = "Gluten"
    
    static var allAllergenStrings: [String] {
        return Allergen.allCases.map { $0.rawValue }
    }
}
