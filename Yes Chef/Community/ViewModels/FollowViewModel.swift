//
//  FollowViewModel.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//
import Foundation
import Observation
import FirebaseFirestore

@Observable class FollowViewModel {
    func follow(other_userID: String, self_userID: String) async {
        if other_userID == self_userID {
            return
        }
        let db = Firestore.firestore()
        
        let self_ref = db.collection("users")
            .document(self_userID)
        
        let other_ref = db.collection("users")
            .document(other_userID)
       
        
        do{
            try await self_ref.updateData(["following": FieldValue.arrayUnion([other_userID])])
            
            try await other_ref.updateData(["followers": FieldValue.arrayUnion([self_userID])])
            
        } catch {
            print("Error adding document:\(error.localizedDescription)")
        }
        
    }
    
    func unfollow(other_userID: String, self_userID: String) async {
        if other_userID == self_userID {
            return
        }
        let db = Firestore.firestore()
        
        let self_ref = db.collection("users")
            .document(self_userID)
        
        let other_ref = db.collection("users")
            .document(other_userID)
       
        
        do{
            try await self_ref.updateData(["following": FieldValue.arrayRemove([other_userID])])
            
            try await other_ref.updateData(["followers": FieldValue.arrayRemove([self_userID])])
            
        } catch {
            print("Error removing document:\(error.localizedDescription)")
        }
    }
}
