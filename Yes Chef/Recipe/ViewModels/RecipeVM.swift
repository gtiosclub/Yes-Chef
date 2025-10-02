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

@Observable class RecipeVM {
    
    func createRecipe(userId: String, name: String, ingredients: [String], allergens: [String], tags: [String], steps: [String], description: String, prepTime: Int, difficulty: Difficulty, media: [String]) async -> String {
        
        let recipeID = UUID()
        let recipeUUID = recipeID.uuidString
        
        let db = Firestore.firestore()
        let storage = Storage.storage()
        var mediaURLs: [String] = []
        
        for file in media {
            let fileURL = URL(fileURLWithPath: file)
            let fileName = fileURL.lastPathComponent
            let ref = storage.reference().child("recipes/\(recipeUUID)/\(fileName)")
            
            do {
                let _ = try await ref.putFileAsync(from: fileURL)
                let downloadURL = try await ref.downloadURL()
                
                mediaURLs.append(downloadURL.absoluteString)
            } catch {
                print("Failed to upload \(fileName): \(error.localizedDescription)")
            }
        }
        
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
            "media": mediaURLs
        ]
        
        do {
            try await db.collection("RECIPES").document(recipeUUID).setData(data)
            print("Document added successfully!")
        } catch {
            print("Error adding document: \(error.localizedDescription)")
        }
        
        return recipeUUID
    }
}
