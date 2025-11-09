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
    var ingredients: [Ingredient] = [Ingredient()]
    var selectedAllergens: [SearchableValue<Allergen>] = []
    var selectedTags: [SearchableValue<Tag>] = []
    var prepTimeInput: String = ""
    var difficulty: Difficulty = .easy
    var servingSize: Int = 1
    var steps: [String] = [""]
    var mediaItems: [MediaItem] = []
    var chefsNotes = ""
    
    var messages: [SmartMessage] = []
    var isThinking: Bool = false
    
    var toolcall: [ToolCallEntry]? = nil
    
    private let ai = AIViewModel()
    
    var allergens: [String] {
        selectedAllergens.map { $0.displayName }
    }
    
    var tags: [String] {
        selectedTags.map { $0.displayName }
    }

    var prepTime: Int { Int(prepTimeInput) ?? 0 }
    
    // Validation
    func validate() -> (isValid: Bool, errorMessage: String?) {
        // Check name
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return (false, "Please enter a recipe name")
        }

        // Check ingredients - at least one ingredient with a name
        let validIngredients = ingredients.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if validIngredients.isEmpty {
            return (false, "Please add at least one ingredient")
        }

        // Check steps - at least one non-empty step
        let validSteps = steps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if validSteps.isEmpty {
            return (false, "Please add at least one step")
        }

        // Check prep time
        if prepTime <= 0 {
            return (false, "Please enter a valid prep time (greater than 0)")
        }

        return (true, nil)
    }
    
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
            let filteredIngredients = ingredients.filter { !removingSet.contains($0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) }

            var existingSet = Set(filteredIngredients.map { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            var updatedIngredients = filteredIngredients

            for addingItem in adding {
                switch addingItem {
                case .ingredient(let newIngredient):
                    let key = newIngredient.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingSet.contains(key) {
                        updatedIngredients.append(newIngredient)
                        existingSet.insert(key)
                    }
                case .string(let ingredientString):
                    let key = ingredientString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingSet.contains(key) {
                        updatedIngredients.append(
                            Ingredient(name: ingredientString.trimmingCharacters(in: .whitespacesAndNewlines))
                        )
                        existingSet.insert(key)
                    }
                }
            }

            self.ingredients = updatedIngredients



            
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
    
    func addRecipeToRemixTreeAsRoot(recipeID: String, postName: String, description: String) async {
        let db = Firestore.firestore()

        let nodeInfo: [String: Any] = [
            "postName": postName,
            "childrenIDs": [],
            "description": description,
            "parentID": "",
            "rootPostID": recipeID,
        ]

        do {
            try await db.collection("REMIXTREENODES").document(recipeID).setData(nodeInfo)
            print("✅ Added recipe \(recipeID) as root node to REMIXTREENODES")
        } catch {
            print("❌ Error adding root node: \(error.localizedDescription)")
        }
    }
    
    func sendMessage(userMessage: String) async {
        let trimmed = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(.init(sender: .user, text: trimmed))
        isThinking = true
        defer { isThinking = false }

        do {
            let suggestion = try await ai.smartSuggestion(recipe: toRecipeForAI(), userMessage: trimmed)

            // Handle toolcall here
            toolcall = suggestion.toolcall

            messages.append(.init(sender: .aiChef, text: suggestion.message))
            print(messages)

        } catch {
            messages.append(.init(sender: .aiChef, text: "Sorry, I couldn't process that. Please try again."))
            print("smartSuggestion error:", error)
        }
    }
    
    func deny() {
        toolcall = nil
    }

    func approve() {
        guard let toolcalls = toolcall else { return }
        
        // Loop through all toolcalls and apply each one
        for toolCall in toolcalls {
            applyChanges(toolCall: toolCall)
        }
        
        // Reset toolcall after applying
        toolcall = nil
    }

    private func toRecipeForAI() -> Recipe {
        Recipe(
            userId: userIdInput,
            recipeId: "temp",
            name: name,
            ingredients: ingredients,
            allergens: allergens,
            tags: tags,
            steps: steps,
            description: description,
            prepTime: Int(prepTimeInput) ?? 0,
            difficulty: difficulty,
            servingSize: servingSize,
            media: [],
            chefsNotes: chefsNotes,
            likes: 0
        )
    }
  
    func addRecipeToRemixTreeAsNode(postName: String, recipeID: String, description: String, parentID: String) async {
        let db = Firestore.firestore()

        print("🔍 Attempting to add recipe \(recipeID) as child of parent \(parentID)")
        print("   Recipe name: \(postName)")

        // Fetch parent node to get root ID and verify it exists
        var rootPostID = parentID
        do {
            let parent = try await db.collection("REMIXTREENODES").document(parentID).getDocument()

            if !parent.exists {
                print("⚠️ Parent recipe \(parentID) does NOT exist in REMIXTREENODES!")
                print("🔧 Auto-fixing: Adding parent as root node first...")

                // Add the parent as a root node (backward compatibility fix)
                await addRecipeToRemixTreeAsRoot(recipeID: parentID, postName: postName, description: "Original recipe (auto-added)")

                // Now the parent exists as a root, so rootPostID is the parent itself
                rootPostID = parentID
                print("✅ Parent successfully added as root node")
            } else if let parentInfo = parent.data(), let parentRoot = parentInfo["rootPostID"] as? String {
                rootPostID = parentRoot
                print("✅ Found parent node. Root is: \(rootPostID)")
            } else {
                print("⚠️ Parent exists but missing rootPostID field, using parentID as root")
                rootPostID = parentID
            }
        } catch {
            print("❌ Error fetching parent node: \(error.localizedDescription)")
            return
        }

        let nodeInfo: [String: Any] = [
            "childrenIDs": [],
            "description": description,
            "parentID": parentID,
            "postName": postName,
            "rootPostID": rootPostID,
        ]

        do {
            try await db.collection("REMIXTREENODES").document(recipeID).setData(nodeInfo)
            print("✅ Added recipe \(recipeID) as child node to REMIXTREENODES (parent: \(parentID))")
            print("   Node info: \(nodeInfo)")

            // Update parent's childrenIDs array
            try await db.collection("REMIXTREENODES").document(parentID).updateData([
                "childrenIDs": FieldValue.arrayUnion([recipeID])
            ])
            print("✅ Updated parent node \(parentID) with new child \(recipeID)")
            
            // Verify the update
            let verifyParent = try await db.collection("REMIXTREENODES").document(parentID).getDocument()
            if let parentData = verifyParent.data() {
                print("✅ Verification - Parent's childrenIDs: \(parentData["childrenIDs"] ?? "empty")")
            }
        } catch {
            print("❌ Error adding child node: \(error.localizedDescription)")
            print("   Full error: \(error)")
        }
    }
    
    func createRecipe(userId: String, name: String, ingredients: [Ingredient], allergens: [String], tags: [String], steps: [String], description: String, prepTime: Int, difficulty: Difficulty, servingSize: Int, media: [MediaItem], chefsNotes: String, submitToWeeklyChallenge: Bool = false) async -> String {

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
            "chefsNotes": chefsNotes,
            "likes": 0
        ]

        do {
            try await db.collection("RECIPES").document(recipeUUID).setData(data)
            print("Document added successfully!")

            // If submitting to weekly challenge, copy to CURRENT_CHALLENGE_SUBMISSIONS
            if submitToWeeklyChallenge {
                print("🏆 Submitting recipe to weekly challenge...")
                try await db.collection("CURRENT_CHALLENGE_SUBMISSIONS").document(recipeUUID).setData([
                    "recipeId": recipeUUID,
                    "submittedAt": FieldValue.serverTimestamp()
                ])
                print("✅ Recipe submitted to weekly challenge!")
            }
        } catch {
            print("Error adding document: \(error.localizedDescription)")
        }

        return recipeUUID
    }

    // Reset all fields to initial state
    func reset() {
        userIdInput = ""
        name = ""
        description = ""
        ingredients = [Ingredient()]
        selectedAllergens = []
        selectedTags = []
        prepTimeInput = ""
        difficulty = .easy
        servingSize = 1
        steps = [""]
        mediaItems = []
        chefsNotes = ""
        messages = []
        isThinking = false
        toolcall = nil
    }
}
