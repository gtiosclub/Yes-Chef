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
        let snapshot = try await db.collection("RECIPES").getDocuments()
        
        self.recipes = snapshot.documents.compactMap { document in
            let data = document.data()
            
            let userId = data["userId"] as? String ?? ""
            let recipeId = document.documentID
            //let recipeId = data["id"] as? String ?? UUID().uuidString
            //let mediaURL = data["profileImageURL"] as? String
            //let media = mediaURL != nil ? [mediaURL!] : []
            
            let name = data["name"] as? String ?? "Untitled"
            let media = data["media"] as? [String] ?? []
            let ingredients: [String] = data["ingredients"] as? [String] ?? []
            let allergens: [String] = data["allergens"] as? [String] ?? []
            let tags: [String] = data["tags"] as? [String] ?? []
            let steps: [String] = data["steps"] as? [String] ?? []
            let description = data["description"] as? String ?? ""
            let servingSize = data["servingSize"] as? Int ?? 1
            let prepTime = data["prepTime"] as? Int ?? 0
            let difficulty = data["difficulty"] as? Difficulty ?? Difficulty.easy
            let chefsNotes = data["chefsNotes"] as? String ?? ""
            
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
                servingSize: servingSize,
                media: media,
                chefsNotes: chefsNotes
            )
        }
    }
    
    //updates the number of likes for a specific recipe in the firestore
    //recipeId is the identifier of the recipe 
    func likePost(recipeId: String) async throws {
        let recipeRef = db.collection("userRecipes").document(recipeId)
        
        _ = try await db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let snapshot = try transaction.getDocument(recipeRef)
                let currentLikes = snapshot.data()?["likes"] as? Int ?? 0
                transaction.updateData(["likes": currentLikes + 1], forDocument: recipeRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
        
        // Update the local UI to display the changes
        if let index = recipes.firstIndex(where: { $0.recipeId == recipeId }) {
            recipes[index].likes += 1
        }
    }
    
    func fetchComments(for recipeId: String) async throws -> [Comment] {
        let snapshot = try await db.collection("COMMENTS")
                .whereField("recipeID", isEqualTo: recipeId)
                .getDocuments()
        return snapshot.documents.compactMap { doc in
                let data = doc.data()
                return Comment(
                    poster: data["poster"] as? String ?? "Unknown",
                    recipeID: data["recipeID"] as? String ?? recipeId,
                    text: data["text"] as? String ?? "",
                    timestamp: (data["timestamp"] as? Timestamp)?.dateValue()
                )
            }
    }
    
    func postComments(poster: String, recipeID: String, text: String) async throws {
        let commentData: [String : Any] = [
            "poster": poster,
            "recipeID": recipeID,
            "text": text,
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection("COMMENTS").addDocument(data: commentData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
}
