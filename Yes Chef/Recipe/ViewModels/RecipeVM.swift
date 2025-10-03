//
//  RecipeVM.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/18/25.
//

import Foundation
import Observation
import FirebaseFirestore
import FirebaseStorage

class RecipeVM: ObservableObject {

    func uploadMediaData(_ data: Data, fileName: String, recipeUUID: String) async -> String? {
        let storage = Storage.storage()
        let ref = storage.reference().child("recipes/\(recipeUUID)/\(fileName)")
        
        do {
            _ = try await ref.putDataAsync(data)
            let downloadURL = try await ref.downloadURL()
            return downloadURL.absoluteString
        } catch {
            print("Failed to upload \(fileName): \(error.localizedDescription)")
            return nil
        }
    }
    let recipeUUID = UUID().uuidString

    func createRecipe(userId: String,
                      name: String,
                      ingredients: [String],
                      allergens: [String],
                      tags: [String],
                      steps: [String],
                      description: String,
                      prepTime: Int,
                      difficulty: Difficulty,
                      media: [String]
                      ) async -> String {
        
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "userId": userId,
            "name": name,
            "ingredients": ingredients,
            "allergens": allergens,
            "tags": tags,
            "steps": steps,
            "description": description,
            "prepTime": prepTime,
            "difficulty": difficulty.rawValue,
            "media": media
        ]
        
        do {
            try await db.collection("RECIPES").document(recipeUUID).setData(data)
            print("Recipe created successfully with ID: \(recipeUUID)")
        } catch {
            print("Error adding recipe: \(error.localizedDescription)")
        }
        
        return recipeUUID
    }
}
