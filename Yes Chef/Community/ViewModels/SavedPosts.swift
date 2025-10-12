//
//  SavedPosts.swift
//  Yes Chef
//
//  Created by Aryan Patel on 10/2/25.
//

import FirebaseFirestore

class SavedPosts {
    private let db = Firestore.firestore()
    
    // Save recipe
    func saveRecipe(_ recipe: Recipe, userId: String, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "recipeId": recipe.recipeId,
            "savedAt": Timestamp(date: Date())
        ]
        
        db.collection("users")
            .document(userId)
            .collection("savedRecipes")
            .document(recipe.recipeId)
            .setData(data, completion: completion)
    }

    // Remove saved recipe
    func removeRecipe(_ recipe: Recipe, userId: String, completion: @escaping (Error?) -> Void) {
        db.collection("users")
            .document(userId)
            .collection("savedRecipes")
            .document(recipe.recipeId)
            .delete(completion: completion)
    }

    // Check if a recipe is saved
    func isRecipeSaved(_ recipe: Recipe, userId: String, completion: @escaping (Bool) -> Void) {
        db.collection("users")
            .document(userId)
            .collection("savedRecipes")
            .document(recipe.recipeId)
            .getDocument { snapshot, _ in
                completion(snapshot?.exists ?? false)
            }
    }

    // Fetch saved recipes
    func fetchSavedRecipes(userId: String, completion: @escaping ([Recipe]) -> Void) {
        let savedRef = db.collection("users").document(userId).collection("savedRecipes")
        
        savedRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching saved IDs: \(error)")
                completion([])
                return
            }
            
            let recipeIds = snapshot?.documents.compactMap { $0.data()["recipeId"] as? String } ?? []
            
            if recipeIds.isEmpty {
                completion([])
                return
            }
            
            self.db.collection("RECIPES")
                .whereField(FieldPath.documentID(), in: recipeIds)
                .getDocuments { recipesSnap, error in
                    if let error = error {
                        print("Error fetching recipes: \(error)")
                        completion([])
                        return
                    }
                    
                    let recipes = recipesSnap?.documents.compactMap { doc -> Recipe? in
                        let data = doc.data()
                        return self.dictToRecipe(data, recipeId: doc.documentID)
                    } ?? []
                    
                    completion(recipes)
                }
        }
    }
    
    // Convert Firestore data → Recipe
    private func dictToRecipe(_ dict: [String: Any], recipeId: String) -> Recipe? {
        guard
            let userId = dict["userId"] as? String,
            let name = dict["name"] as? String,
            let ingredients = dict["ingredients"] as? [String],
            let allergens = dict["allergens"] as? [String],
            let tags = dict["tags"] as? [String],
            let steps = dict["steps"] as? [String],
            let description = dict["description"] as? String,
            let servingSize = dict["servingSize"] as? Int,
            let prepTime = dict["prepTime"] as? Int,
            let difficultyRaw = dict["difficulty"] as? String,
            let difficulty = Difficulty(rawValue: difficultyRaw),
            let media = dict["media"] as? [String]
        else {
            return nil
        }
        
        let recipe = Recipe(
            userId: userId,
            recipeId: recipeId,
            name: name,
            ingredients: ingredients,
            allergens: allergens,
            tags: tags,
            steps: steps,
            description: description,
            prepTime: prepTime,
            difficulty: difficulty,
            servingSize: servingSize,
            media: media
        )
        
        recipe.likes = dict["likes"] as? Int ?? 0
        recipe.comments = dict["comments"] as? [String] ?? []
        
        return recipe
    }
}
