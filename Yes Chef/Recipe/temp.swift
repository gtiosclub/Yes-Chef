//
//  temp.swift
//  Yes Chef
//
//  Created by Sam Orouji on 9/7/25.
//

import Foundation

struct RecipeeModel {
    let userId: String
    var title: String
    var ingredients: [String]
    var allergens: [String]
    var steps: [String]
    var description: String
    var prepTime: Int
    var Difficulty: Difficulty
    
    enum Difficulty: String, CaseIterable, Codable {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
        
        var displayName: String {
            return rawValue.capitalized
        }
        
        var emoji: String {
            switch self {
            case .easy: return "🟢"
            case .medium: return "🟡"
            case .hard: return "🔴"
            }
        }
    }
    
}
