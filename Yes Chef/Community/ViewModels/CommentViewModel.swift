//
//  CommentViewModel.swift
//  Yes Chef
//
//  Created by Kushi Kashyap on 10/30/25.
//
import FirebaseFirestore
import SwiftUI

class CommentsViewModel: ObservableObject {
    @Published var comments = [Comment]()
    @Published var newCommentText = ""
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    // Fetch comments for a recipe
    func fetchComments(for recipeID: String) {
        db.collection("comments")
            .whereField("recipeID", isEqualTo: recipeID)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self.comments = documents.compactMap { try? $0.data(as: Comment.self) }
            }
    }
    
    // Post a new comment
    func postComment(for recipeID: String, poster: String) {
        let comment = Comment(
            poster: poster,
            recipeID: recipeID,
            text: newCommentText,
            timestamp: Date()
        )
        
        do {
            _ = try db.collection("comments").addDocument(from: comment)
            newCommentText = ""
        } catch {
            print("Error adding comment: \(error)")
        }
    }
}
