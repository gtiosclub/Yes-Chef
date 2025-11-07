//
//  Recipe.swift
//  Yes Chef
//
//  Created by Neel Bhattacharyya on 9/18/25.
//

import Foundation
import Observation
import FirebaseFirestore

enum Difficulty: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

@Observable class Recipe: Identifiable {
    var id: String {recipeId}
    var userId: String
    var recipeId: String
    var name: String
    var ingredients: [Ingredient]
    var allergens: [String]
    var tags: [String]
    var steps: [String]
    var description: String
    var prepTime: Int
    var difficulty: Difficulty
    var servingSize: Int
    var media: [String]
    var chefsNotes: String
    var likes: Int
    
    var comments: [String] = []
    

    init(userId: String, recipeId: String, name: String, ingredients: [Ingredient], allergens: [String], tags: [String], steps: [String], description: String, prepTime: Int, difficulty: Difficulty, servingSize: Int, media: [String], chefsNotes: String, likes: Int) {
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
        self.servingSize = servingSize
        self.media = media
        self.chefsNotes = chefsNotes
        self.likes = likes
    }

    /// Fetches a recipe from Firebase by ID
    /// - Parameter id: The recipe ID to fetch
    /// - Returns: A Recipe object if found, nil otherwise
    static func fetchById(_ id: String) async -> Recipe? {
        let db = Firestore.firestore()

        do {
            let document = try await db.collection("RECIPES").document(id).getDocument()

            guard document.exists, let data = document.data() else {
                print("Recipe with ID \(id) does not exist")
                return nil
            }

            // Parse basic fields
            guard let userId = data["userId"] as? String,
                  let name = data["name"] as? String else {
                print("Missing required fields for recipe \(id)")
                return nil
            }

            // Parse ingredients from array of dictionaries
            let ingredientsData = data["ingredients"] as? [[String: Any]] ?? []
            let ingredients = ingredientsData.compactMap { ingredientDict -> Ingredient? in
                guard let name = ingredientDict["name"] as? String else { return nil }

                let quantity: Int
                if let intQuantity = ingredientDict["quantity"] as? Int {
                    quantity = intQuantity
                } else if let doubleQuantity = ingredientDict["quantity"] as? Double {
                    quantity = Int(doubleQuantity)
                } else {
                    quantity = 0
                }

                let unit = ingredientDict["unit"] as? String ?? ""
                let preparation = ingredientDict["preparation"] as? String ?? ""

                return Ingredient(name: name, quantity: quantity, unit: unit, preparation: preparation)
            }

            // Parse other fields with defaults
            let allergens = data["allergens"] as? [String] ?? []
            let tags = data["tags"] as? [String] ?? []
            let steps = data["steps"] as? [String] ?? []
            let description = data["description"] as? String ?? ""
            let prepTime = data["prepTime"] as? Int ?? 0
            let servingSize = data["servingSize"] as? Int ?? 1
            let media = data["media"] as? [String] ?? []
            let chefsNotes = data["chefsNotes"] as? String ?? ""

            // Parse difficulty
            let difficultyString = data["difficulty"] as? String ?? "Easy"
            let difficulty = Difficulty(rawValue: difficultyString) ?? .easy

            // Create and return the recipe
            let recipe = Recipe(
                userId: userId,
                recipeId: document.documentID,
                name: name,
                ingredients: ingredients,
                allergens: allergens,
                tags: tags,
                steps: steps,
                description: description,
                prepTime: prepTime,
                difficulty: difficulty,
                servingSize: servingSize,
                media: media,
                chefsNotes: chefsNotes,
                likes: 0
            )

            // Set optional fields if they exist
            recipe.likes = data["likes"] as? Int ?? 0
            recipe.comments = data["comments"] as? [String] ?? []

            return recipe

        } catch {
            print("Error fetching recipe \(id): \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Hashable Conformance
extension Recipe: Hashable {
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.recipeId == rhs.recipeId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(recipeId)
    }
}
