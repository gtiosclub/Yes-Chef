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
    var selectedIngredients: [SearchableValue<Ingredient>] = []
    var selectedAllergens: [SearchableValue<Allergen>] = []
    var selectedTags: [SearchableValue<Tag>] = []
    var prepTimeInput: String = ""
    var difficulty: Difficulty = .easy
    var servingSize: Int = 1
    var steps: [String] = [""]
    var mediaItems: [MediaItem] = []
    var chefsNotes = ""
    
    var ingredients: [String] {
        selectedIngredients.map { $0.displayName }
    }
    
    var allergens: [String] {
        selectedAllergens.map { $0.displayName }
    }
    
    var tags: [String] {
        selectedTags.map { $0.displayName }
    }

    var prepTime: Int { Int(prepTimeInput) ?? 0 }
    
    // Default initializer
    init() {}
    
    // Initializer for remixing - populates fields from existing recipe
    init(fromRecipe recipe: Recipe) {
        self.userIdInput = recipe.userId
        self.name = recipe.name
        self.description = recipe.description
        self.prepTimeInput = String(recipe.prepTime)
        self.difficulty = recipe.difficulty
        self.servingSize = recipe.servingSize
        self.steps = recipe.steps.isEmpty ? [""] : recipe.steps
        self.chefsNotes = recipe.chefsNotes
        
        // Convert ingredients to SearchableValue
        self.selectedIngredients = recipe.ingredients.map { ingredient in
            if let matchingIngredient = Ingredient.allIngredients.first(where: {
                $0.displayName.lowercased() == ingredient.lowercased()
            }) {
                return .predefined(matchingIngredient)
            } else {
                return .custom(ingredient)
            }
        }
        
        // Convert allergens to SearchableValue
        self.selectedAllergens = recipe.allergens.filter { !$0.isEmpty }.map { allergen in
            if let matchingAllergen = Allergen.allCases.first(where: {
                $0.displayName.lowercased() == allergen.lowercased()
            }) {
                return .predefined(matchingAllergen)
            } else {
                return .custom(allergen)
            }
        }
        
        // Convert tags to SearchableValue
        self.selectedTags = recipe.tags.map { tag in
            if let matchingTag = Tag.allTags.first(where: {
                $0.displayName.lowercased() == tag.lowercased()
            }) {
                return .predefined(matchingTag)
            } else {
                return .custom(tag)
            }
        }
        
        // Note: Media URLs from Firebase can't be directly used as local paths
        // You may want to download these images or handle them differently
        // For now, they won't be populated in localMediaPaths
    }

    func applyChanges(item: String, removing: [String], adding: [String]) {
            switch item.lowercased() {
            case "title":
                if let newTitle = adding.first {
                    name = newTitle
                }
                
            case "ingredients":
                let removingSet = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
                selectedIngredients.removeAll { value in
                    removingSet.contains(value.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
                }
                
                let existingSet = Set(selectedIngredients.map { $0.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
                for add in adding {
                    let key = add.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingSet.contains(key) {
                        if let matchingIngredient = Ingredient.allIngredients.first(where: {
                            $0.displayName.lowercased() == key
                        }) {
                            selectedIngredients.append(.predefined(matchingIngredient))
                        } else {
                            selectedIngredients.append(.custom(add.trimmingCharacters(in: .whitespacesAndNewlines)))
                        }
                    }
                }
                
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
    

    private func uploadMediaToFirebase(_ localPath: URL, mediaItem: MediaItem, fileName: String, recipeUUID: String) async -> String? {
        let storage = Storage.storage()
        let contentType = mediaItem.mediaType == .video ? "video/quicktime" : "image/jpeg"
        let path = "recipes/\(recipeUUID)/\(fileName)"
        let ref = storage.reference().child(path)
        
        do {
            let data = try Data(contentsOf: mediaItem.localPath)
            
            let metadata = StorageMetadata()
            metadata.contentType = contentType
            metadata.customMetadata = ["mediaType": mediaItem.mediaType == .video ? "video" : "photo"]
            
            let _ = try await ref.putDataAsync(data, metadata: metadata)
            let downloadURL = try await ref.downloadURL()
            
            print("Uploaded \(fileName) successfully")
            return downloadURL.absoluteString
        } catch {
            print("Failed to upload \(fileName): \(error.localizedDescription)")
            return nil
        }
    }
    
    func addRecipeToRemixTreeAsRoot(description: String) async -> String {
        let postID = UUID()
        let postUUID = postID.uuidString
        
        let db = Firestore.firestore()
        
        let nodeInfo: [String: Any] = [
            "postID": postUUID,
            "childrenID": [],
            "description": description,
            "parentID": "",
            "rootNodeID": postUUID,
        ]
        
        do {
            try await db.collection("remixTreeNode").document(postUUID).setData(nodeInfo)
            print("Document added successfully!")
        } catch {
            print("Error adding document: \(error.localizedDescription)")
        }
        return postUUID
    }
    
    func createRecipe(userId: String, name: String, ingredients: [String], allergens: [String], tags: [String], steps: [String], description: String, prepTime: Int, difficulty: Difficulty, servingSize: Int, mediaItems: [MediaItem], chefsNotes: String) async -> String {
        
        let recipeID = UUID()
        let recipeUUID = recipeID.uuidString
        
        let db = Firestore.firestore()
        var uploadedMediaURLs: [String] = []
        
        for (index, mediaItem) in mediaItems.enumerated() {
            let ext = mediaItem.mediaType == .video ? "mov" : "jpg"
            let fileName = "media_\(index).\(ext)"
            
            if let urlString = await uploadMediaToFirebase(
                mediaItem,
                fileName: fileName,
                recipeUUID: recipeUUID
            ) {
                uploadedMediaURLs.append(urlString)
            }
        }
        
        print("All uploaded media: \(uploadedMediaURLs)")
        
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
            "servingSize": servingSize,
            "media": uploadedMediaURLs,
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
