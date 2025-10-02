//
//  Recipe.swift
//  Yes Chef
//
//  Created by Neel Bhattacharyya on 9/18/25.
//

import Foundation
import Observation

enum Difficulty: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
}

@Observable class Recipe: Identifiable {
    var id: String {recipeId}
    var userId: String
    var recipeId: String
    var name: String
    var ingredients: [String]
    var allergens: [String]
    var tags: [String]
    var steps: [String]
    var description: String
    var prepTime: Int
    var difficulty: Difficulty
    var media: [String]
    
    var likes: Int = 0
    var comments: [String] = []
    
    init(userId: String, recipeId: String, name: String, ingredients: [String], allergens: [String], tags: [String], steps: [String], description: String, prepTime: Int, difficulty: Difficulty, media: [String]) {
        self.userId = userId
        self.recipeId = recipeId
        self.name = name
        self.ingredients = ingredients
        self.allergens = allergens
        self.tags = tags
        self.steps = steps
        self.description = description
        self.prepTime = prepTime
        self.difficulty = difficulty
        self.media = media
    }
}
