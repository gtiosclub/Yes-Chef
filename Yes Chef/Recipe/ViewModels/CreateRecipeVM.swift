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
import SwiftUI

@Observable class CreateRecipeVM {
    var userIdInput: String = ""
    var name: String = ""
    var description: String = ""
    var ingredients: [Ingredient] = []
    var selectedAllergens: [SearchableValue<Allergen>] = []
    var selectedTags: [SearchableValue<Tag>] = []
    var prepTimeInput: String = ""
    var difficulty: Difficulty = .easy
    var servingSize: Int = 1
    var steps: [String] = [""]
    var selectedImages: [Image] = []
    var localMediaPaths: [URL] = []
    var chefsNotes = ""
    
    var allergens: [String] {
        selectedAllergens.map { $0.displayName }
    }
    
    var tags: [String] {
        selectedTags.map { $0.displayName }
    }

    var prepTime: Int { Int(prepTimeInput) ?? 0 }

    func applyChanges(item: String, removing: [String], adding: [String]) {
            switch item.lowercased() {
            case "title":
                if let newTitle = adding.first {
                    name = newTitle
                }
                
//            case "ingredients":
//                let removingSet = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
//                selectedIngredients.removeAll { value in
//                    removingSet.contains(value.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
//                }
//                
//                let existingSet = Set(selectedIngredients.map { $0.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
//                for add in adding {
//                    let key = add.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//                    if !existingSet.contains(key) {
//                        if let matchingIngredient = Ingredient.allIngredients.first(where: {
//                            $0.displayName.lowercased() == key
//                        }) {
//                            selectedIngredients.append(.predefined(matchingIngredient))
//                        } else {
//                            selectedIngredients.append(.custom(add.trimmingCharacters(in: .whitespacesAndNewlines)))
//                        }
//                    }
//                }
                
            case "allergens":
                let removingSet = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
                selectedAllergens.removeAll { value in
                    removingSet.contains(value.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
                }
                
                let existingSet = Set(selectedAllergens.map { $0.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
                for add in adding {
                    let key = add.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingSet.contains(key) {
                        if let matchingAllergen = Allergen.allCases.first(where: {
                            $0.displayName.lowercased() == key
                        }) {
                            selectedAllergens.append(.predefined(matchingAllergen))
                        } else {
                            selectedAllergens.append(.custom(add.trimmingCharacters(in: .whitespacesAndNewlines)))
                        }
                    }
                }
                
            case "tags":
                let removingSet = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
                selectedTags.removeAll { value in
                    removingSet.contains(value.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
                }
                
                let existingSet = Set(selectedTags.map { $0.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
                for add in adding {
                    let key = add.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingSet.contains(key) {
                        if let matchingTag = Tag.allTags.first(where: {
                            $0.displayName.lowercased() == key
                        }) {
                            selectedTags.append(.predefined(matchingTag))
                        } else {
                            selectedTags.append(.custom(add.trimmingCharacters(in: .whitespacesAndNewlines)))
                        }
                    }
                }
                
            default:
                break
            }
        }
    
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
    
    func createRecipe(userId: String, name: String, ingredients: [Ingredient], allergens: [String], tags: [String], steps: [String], description: String, prepTime: Int, difficulty: Difficulty, servingSize: Int, media: [URL], chefsNotes: String) async -> String {
        
        let recipeID = UUID()
        let recipeUUID = recipeID.uuidString
        
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
        
        let ingredientsData = ingredients.map { ingredient in
            [
                "name": ingredient.name,
                "quantity": ingredient.quantity,
                "unit": ingredient.unit,
                "preparation": ingredient.preparation
            ] as [String: Any]
        }
        
        let data: [String: Any] = [
            "userId": userId,
            "name": name,
            "ingredients": ingredientsData,
            "allergens": allergens,
            "tags": tags,
            "steps": steps,
            "description": description,
            "prepTime": prepTime,
            "difficulty": difficulty.rawValue,
            "servingSize": servingSize,
            "media": uploadedURLs,
            "chefsNotes": chefsNotes
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
