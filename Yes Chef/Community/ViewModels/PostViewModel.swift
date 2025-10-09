//
//  PostViewModel.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//
import Foundation
import Observation
import FirebaseFirestore

@Observable class PostViewModel   {
    var posts: [Recipe] = []
    private var db = Firestore.firestore()
    
    func fetchPosts() async throws {
        //get all the posts in the collection RECIPES
        db.collection("RECIPES").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching recipes: \(error)")
                return
            }
            DispatchQueue.main.async {
                self.posts = snapshot?.documents.compactMap{ doc in
                    let data = doc.data()
                    
                    let allergens = data["allergens"] as? [String] ?? []
                    let description = data["description"] as? String ?? "Unknown"
                    let difficultystr = data["difficulty"] as? String ?? "Unknown"
                    let ingredients = data["ingredients"] as? [String] ?? []
                    let media = data["media"] as? [String] ?? []
                    let name = data["name"] as? String ?? "Unknown"
                    let prepTime = data["prepTime"] as? Int ?? 0
                    let steps = data["steps"] as? [String] ?? []
                    let tags = data["tags"] as? [String] ?? []
                    let userId = data["userId"] as? String ?? "Unknown"
                    
                    let difficulty = Difficulty(rawValue: difficultystr.lowercased()) ?? .easy
                    return Recipe (
                        userId: userId,
                        recipeId: doc.documentID,
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
                } ?? []
            }
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
