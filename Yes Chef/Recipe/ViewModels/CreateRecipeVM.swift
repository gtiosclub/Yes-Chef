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
    var mediaItems: [MediaItem] = []
    var chefsNotes = ""
    
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
        self.ingredients = recipe.ingredients
        self.prepTimeInput = String(recipe.prepTime)
        self.difficulty = recipe.difficulty
        self.servingSize = recipe.servingSize
        self.steps = recipe.steps.isEmpty ? [""] : recipe.steps
        self.chefsNotes = recipe.chefsNotes
        
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

    func applyChanges(toolCall: ToolCallEntry) {
        let item = toolCall.item.lowercased()
        let removing = toolCall.removing
        let adding = toolCall.adding
        
        switch item {
        case "title", "name":
            if let firstAdding = adding.first {
                switch firstAdding {
                case .string(let newTitle):
                    name = newTitle
                case .ingredient:
                    print("error")
                }
            }
            
        case "preptime", "prep time":
            if let firstAdding = adding.first {
                switch firstAdding {
                case .string(let newPrepTime):
                    prepTimeInput = newPrepTime
                case .ingredient:
                    print("error")
                }
            }
            
        case "description":
            if let firstAdding = adding.first {
                switch firstAdding {
                case .string(let newDescription):
                    description = newDescription
                case .ingredient:
                    print("error")
                }
            }
            
        case "ingredients":
            let removingSet = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            ingredients.removeAll { ingredient in
                removingSet.contains(ingredient.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            let existingSet = Set(ingredients.map { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            for addingItem in adding {
                switch addingItem {
                case .ingredient(let newIngredient):
                    let key = newIngredient.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingSet.contains(key) {
                        ingredients.append(newIngredient)
                    }
                case .string(let ingredientString):
                    let key = ingredientString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingSet.contains(key) {
                        let newIngredient = Ingredient(
                            name: ingredientString.trimmingCharacters(in: .whitespacesAndNewlines),
                            quantity: 0,
                            unit: "",
                            preparation: ""
                        )
                        ingredients.append(newIngredient)
                    }
                }
            }
            
        case "allergens":
            let removingSet = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            selectedAllergens.removeAll { value in
                removingSet.contains(value.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            let existingSet = Set(selectedAllergens.map { $0.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            for addingItem in adding {
                switch addingItem {
                case .string(let allergenString):
                    let key = allergenString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingSet.contains(key) {
                        if let matchingAllergen = Allergen.allCases.first(where: {
                            $0.displayName.lowercased() == key
                        }) {
                            selectedAllergens.append(.predefined(matchingAllergen))
                        } else {
                            selectedAllergens.append(.custom(allergenString.trimmingCharacters(in: .whitespacesAndNewlines)))
                        }
                    }
                case .ingredient:
                    print("error")
                }
            }
            
        case "tags":
            let removingSet = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            selectedTags.removeAll { value in
                removingSet.contains(value.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            let existingSet = Set(selectedTags.map { $0.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            for addingItem in adding {
                switch addingItem {
                case .string(let tagString):
                    let key = tagString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingSet.contains(key) {
                        if let matchingTag = Tag.allTags.first(where: {
                            $0.displayName.lowercased() == key
                        }) {
                            selectedTags.append(.predefined(matchingTag))
                        } else {
                            selectedTags.append(.custom(tagString.trimmingCharacters(in: .whitespacesAndNewlines)))
                        }
                    }
                case .ingredient:
                    print("error")
                }
            }
            
        case "steps":
            let removingSet = Set(removing.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            steps.removeAll { step in
                removingSet.contains(step.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            let existingSet = Set(steps.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            for addingItem in adding {
                switch addingItem {
                case .string(let stepString):
                    let trimmedStep = stepString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingSet.contains(trimmedStep) && !trimmedStep.isEmpty {
                        steps.append(stepString)
                    }
                case .ingredient:
                    print("error")
                }
            }
            
            if steps.isEmpty {
                steps = [""]
            }
            
        default:
            print("error: \(item)")
        }
    }
    

    private func uploadMediaToFirebase(mediaItem: MediaItem, fileName: String, recipeUUID: String) async -> String? {
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
    
    func addRecipeToRemixTreeAsNode(description: String, parentID: String) async -> String {
        let postID = UUID()
        let postUUID = postID.uuidString
        
        let db = Firestore.firestore()
        
        var rootNodeID = parentID
        do {
            let parent = try await db.collection("remixTreeNode").document(parentID).getDocument()
            if let parentInfo = parent.data(), let parentRoot = parentInfo["rootNodeID"] as? String {
                rootNodeID = parentRoot
            }
        } catch {
            print("⚠️ Could not fetch parent node: \(error.localizedDescription)")
        }
        
        let nodeInfo: [String: Any] = [
            "postID": postUUID,
            "childrenID": [],
            "description": description,
            "parentID": parentID,
            "rootNodeID": rootNodeID,
        ]
            
        do {
            try await db.collection("remixTreeNode").document(postUUID).setData(nodeInfo)
            print("Document added successfully!")
        } catch {
            print("Error adding document: \(error.localizedDescription)")
        }
        return postUUID
    }
    
    func createRecipe(userId: String, name: String, ingredients: [Ingredient], allergens: [String], tags: [String], steps: [String], description: String, prepTime: Int, difficulty: Difficulty, servingSize: Int, media: [MediaItem], chefsNotes: String) async -> String {
        
        let recipeID = UUID()
        let recipeUUID = recipeID.uuidString
        
        let db = Firestore.firestore()
        var uploadedMediaURLs: [String] = []
        
        for (index, mediaItem) in mediaItems.enumerated() {
            let ext = mediaItem.mediaType == .video ? "mov" : "jpg"
            let fileName = "media_\(index).\(ext)"
            
            if let urlString = await uploadMediaToFirebase(
                mediaItem: mediaItem,
                fileName: fileName,
                recipeUUID: recipeUUID
            ) {
                uploadedMediaURLs.append(urlString)
            }
        }
        
        print("All uploaded media: \(uploadedMediaURLs)")
        
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
