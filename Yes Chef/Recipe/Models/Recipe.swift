//
//  Recipe.swift
//  Yes Chef
//
//  Created by Neel Bhattacharyya on 9/18/25.
//

import Foundation
import Firebase

class Recipe: Identifiable, ObservableObject {
    @Published var userId: String
    @Published var recipeId: String
    @Published var name: String
    @Published var ingredients: [String]
    @Published var allergens: [String]
    @Published var tags: [String]
    @Published var steps: [String]
    @Published var description: String
    @Published var PrepTime: Int
    enum Difficulty: String {
        case easy
        case medium
        case hard
    }
    @Published var difficulty: Difficulty
    @Published var media: [String]
    
    
    init(userId: String, recipeId: String, name: String, ingredients: [String], allergens: [String], tags: [String], steps: [String], description: String, PrepTime: Int, difficulty: Difficulty, media: [String]) {
        self.userId = userId
        self.recipeId = recipeId
        self.name = name
        self.ingredients = ingredients
        self.allergens = allergens
        self.tags = tags
        self.steps = steps
        self.description = description
        self.PrepTime = PrepTime
        self.difficulty = difficulty
        self.media = media
    }
    
}
