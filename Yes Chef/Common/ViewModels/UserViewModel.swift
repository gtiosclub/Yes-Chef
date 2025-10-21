//
//  UserViewModel.swift
//  Yes Chef
//
//  Created by Hawthorne Brown on 10/9/25.
//

import Foundation
import Observation
import FirebaseFirestore

@Observable class UserViewModel{
    
    func getUserInfo(userID: String) async -> [String: Any]?{
        let db = Firestore.firestore()
        let batch = db.batch()
        
        let info = db.collection("users")
            .document(userID)
            
        do {
            let doc = try await info.getDocument()
            if doc.exists{
                return doc.data()
            }
        }
        catch {
            print("Error getting document: \(error)")
        }
        
        return nil
    }
    
    // MARK: - Profile Update Functions
    
    func updateUserProfile(userID: String, username: String, bio: String?, profilePhoto: String) async -> Bool {
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "username": username,
            "bio": bio ?? "",
            "profilePhoto": profilePhoto
        ]
        
        do {
            try await db.collection("users").document(userID).updateData(userData)
            print("User profile updated successfully")
            return true
        } catch {
            print("Error updating user profile: \(error)")
            return false
        }
    }
    
    func updateUsername(userID: String, newUsername: String) async -> Bool {
        let db = Firestore.firestore()
        
        do {
            try await db.collection("users").document(userID).updateData(["username": newUsername])
            print("Username updated successfully")
            return true
        } catch {
            print("Error updating username: \(error)")
            return false
        }
    }
    
    func updateBio(userID: String, newBio: String) async -> Bool {
        let db = Firestore.firestore()
        
        do {
            try await db.collection("users").document(userID).updateData(["bio": newBio])
            print("Bio updated successfully")
            return true
        } catch {
            print("Error updating bio: \(error)")
            return false
        }
    }
    
    func updateProfilePhoto(userID: String, photoURL: String) async -> Bool {
        let db = Firestore.firestore()
        
        do {
            try await db.collection("users").document(userID).updateData(["profilePhoto": photoURL])
            print("Profile photo updated successfully")
            return true
        } catch {
            print("Error updating profile photo: \(error)")
            return false
        }
    }
}

