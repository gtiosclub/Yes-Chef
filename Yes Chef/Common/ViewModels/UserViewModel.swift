//
//  UserViewModel.swift
//  Yes Chef
//
//  Created by Hawthorne Brown on 10/9/25.
//

import Foundation
import Observation
import FirebaseFirestore
import UIKit

@Observable class UserViewModel{
    
    func getUserInfo(userID: String) async -> [String: Any]?{
        let db = Firestore.firestore()        
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
        let userData: [String: Any] = [
            "username": username,
            "bio": bio ?? "",
            "profilePhoto": profilePhoto
        ]
        
        do {
            try await Firebase.db.collection("users").document(userID).updateData(userData)
            print("User profile updated successfully")
            return true
        } catch {
            print("Error updating user profile: \(error)")
            return false
        }
    }
    
    // MARK: - Image Upload Functions
    
    func uploadProfileImage(userID: String, image: UIImage) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to data")
            return nil
        }
        
        // For now, we'll store the image data as base64 in Firestore
        // In a production app, you'd want to use Firebase Storage
        let base64String = imageData.base64EncodedString()
        return base64String
    }
    
    func updateUserProfileWithImage(userID: String, username: String, bio: String?, image: UIImage?) async -> Bool {
        var profilePhotoURL = ""
        
        // Upload image if provided
        if let image = image {
            if let uploadedURL = await uploadProfileImage(userID: userID, image: image) {
                profilePhotoURL = uploadedURL
            } else {
                print("Failed to upload image, but continuing with profile update")
            }
        }
        
        // Update profile in Firestore
        return await updateUserProfile(
            userID: userID,
            username: username,
            bio: bio,
            profilePhoto: profilePhotoURL
        )
    }
    
    func updateUsername(userID: String, newUsername: String) async -> Bool {
        do {
            try await Firebase.db.collection("users").document(userID).updateData(["username": newUsername])
            print("Username updated successfully")
            return true
        } catch {
            print("Error updating username: \(error)")
            return false
        }
    }
    
    func updateBio(userID: String, newBio: String) async -> Bool {
        do {
            try await Firebase.db.collection("users").document(userID).updateData(["bio": newBio])
            print("Bio updated successfully")
            return true
        } catch {
            print("Error updating bio: \(error)")
            return false
        }
    }
    
    func updateProfilePhoto(userID: String, photoURL: String) async -> Bool {
        do {
            try await Firebase.db.collection("users").document(userID).updateData(["profilePhoto": photoURL])
            print("Profile photo updated successfully")
            return true
        } catch {
            print("Error updating profile photo: \(error)")
            return false
        }
    }
}

