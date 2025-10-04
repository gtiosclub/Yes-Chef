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

    private func uploadMediaFromLocalPath(_ localPath: URL, fileName: String, recipeUUID: String) async -> String? {
        let storage = Storage.storage()
        let ref = storage.reference().child("recipes/\(recipeUUID)/\(fileName)")
        
        do {
            let data = try Data(contentsOf: localPath)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = try await ref.putDataAsync(data, metadata: metadata)
            let downloadURL = try await ref.downloadURL()
            
            print("Uploaded \(fileName) successfully")
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
                      media: [URL]
                      ) async -> String {
        
        let db = Firestore.firestore()
        var uploadedURLs: [String] = []
        
        for (index, localPath) in media.enumerated() {
            let fileName = "media_\(index).jpg"
            
            if let urlString = await uploadMediaFromLocalPath(
                localPath,
                fileName: fileName,
                recipeUUID: recipeUUID
            ) {
                uploadedURLs.append(urlString)
            }
        }
        
        print("All uploaded media URLs: \(uploadedURLs)")
        
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
            "media": uploadedURLs
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
