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

@Observable class CreateRecipeVM {
    var userIdInput: String = ""
    var name: String = ""
    var description: String = ""
    var ingredientsInput: String = ""
    var allergensInput: String = ""
    var tagsInput: String = ""
    var prepTimeInput: String = ""
    var difficulty: Difficulty = .easy
    var steps: [String] = [""]
    var mediaInputs: [String] = [""]

    private(set) var ingredients: [String] = []
    private(set) var allergens: [String] = []
    private(set) var tags: [String] = []

    private func normalizedArray(from text: String) -> [String] {
        text.split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func onIngredientsChanged(_ text: String) { ingredientsInput = text; ingredients = normalizedArray(from: text) }
    func onAllergensChanged(_ text: String)  { allergensInput  = text; allergens  = normalizedArray(from: text) }
    func onTagsChanged(_ text: String)       { tagsInput       = text; tags       = normalizedArray(from: text) }

    var prepTime: Int { Int(prepTimeInput) ?? 0 }

    func applyChanges(item: String, removing: [String], adding: [String]) {
        switch item.lowercased() {
        case "title":
            if let newTitle = adding.first { name = newTitle }
        case "ingredients":
            var set = Set(ingredients.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            let removingKeys = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            var next = ingredients.filter { !removingKeys.contains($0.lowercased()) }
            for add in adding {
                let key = add.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if !set.contains(key) { next.append(add); set.insert(key) }
            }
            ingredients = next
            ingredientsInput = next.joined(separator: ", ")
        case "allergens":
            var set = Set(allergens.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            let removingKeys = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            var next = allergens.filter { !removingKeys.contains($0.lowercased()) }
            for add in adding {
                let key = add.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if !set.contains(key) { next.append(add); set.insert(key) }
            }
            allergens = next
            allergensInput = next.joined(separator: ", ")
        default:
            break
        }
    }
    
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
