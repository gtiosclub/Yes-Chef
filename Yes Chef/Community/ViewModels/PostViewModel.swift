//
//  PostViewModel.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//
import Foundation
import Observation
import FirebaseFirestore

@Observable
class PostViewModel {
    var recipes: [Recipe] = []
    
    private let db = Firestore.firestore()
    
    func fetchPosts() async throws {
        let snapshot = try await db.collection("userRecipes").getDocuments()
        
        self.recipes = snapshot.documents.compactMap { document in
            let data = document.data()
            
            let userId = data["username"] as? String ?? "Unknown"
            let recipeId = data["id"] as? String ?? UUID().uuidString
            let name = data["recipeName"] as? String ?? "Untitled"
            let mediaURL = data["profileImageURL"] as? String
            let media = mediaURL != nil ? [mediaURL!] : []
            
            let ingredients: [String] = []
            let allergens: [String] = []
            let tags: [String] = []
            let steps: [String] = []
            let description = ""
            let prepTime = 0
            let difficulty = Difficulty.easy
            
            return Recipe(
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
                media: media
            )
        }
    }
}
