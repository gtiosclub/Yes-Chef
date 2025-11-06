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
    let weights : [String: Double] = ["like":0.5,
                                      "share":0.6,
                                      "save":0.7,
                                      "comment": 0.8,
                                      "view": 0.1
    
    ]
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

    func like(recipeID: String, userID: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        do {
            try await userRef.updateData(["likedRecipes": FieldValue.arrayUnion([recipeID])])

        } catch {
            print("Error adding document:\(error.localizedDescription)")
        }
    }
    
    func unlike(recipeID: String, userID: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        do {
            try await userRef.updateData(["likedRecipes": FieldValue.arrayRemove([recipeID])])
            
        } catch {
            print("Error adding document:\(error.localizedDescription)")
        }
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
    
    func updateUser(userID: String) async -> User{
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        do {
            let document = try await userRef.getDocument()
            let data = document.data()
            let profilePhotoURL = data?["profilePhoto"] as? String ?? ""
            let username = data?["username"] as? String ?? "username"
            let bio = data?["bio"] as? String ?? "bio"
            let email = data?["email"] as? String ?? "email"
            let followers = data?["followers"] as? [String] ?? []
            let following = data?["following"] as? [String] ?? []
            let likedRecipes = data?["likedRecipes"] as? [String] ?? []
            let savedRecipes = data?["savedRecipes"] as? [String] ?? []
            let badges = data?["badges"] as? [String] ?? []
            let tempuser = User(userId: userID, username: username, email: email, bio: bio, password: "")
            tempuser.following = following
            tempuser.followers = followers
            tempuser.likedRecipes = likedRecipes
            tempuser.savedRecipes = savedRecipes
            tempuser.badges = badges
            print("User \(username) updated!")
            return tempuser
        } catch {
            print("Can't find user")
        }
        return User(userId: "userID", username: "username", email: "email", bio: "bio", password: "")
    }
    
    func updateSuggestionProfile(userID: String, suggestionProfile: inout [String: Double], recipe: Recipe, interaction: String) async {
        guard let multiplier = weights[interaction] else { return }
        for tag in recipe.tags {
            suggestionProfile[tag, default: 1.0] += multiplier
        }
        
        do {
            try await Firebase.db.collection("users").document(userID).updateData(["suggestionProfile": suggestionProfile])
            print("SuggestionProfile updated successfully")
        } catch {
            print("Error updating suggestionProfile: \(error)")
        }
    }
    //function to determine similarity of recipe to user suggestion profile
    func calculateScore(recipe: Recipe, user: [String: Double]) -> Double{
        let commonKeys = Set(user.keys).intersection(recipe.tags)
            
        let dot = recipe.tags.reduce(0.0) { $0 + (user[$1] ?? 1.0) }
        let userMagnitude = sqrt(user.values.reduce(0.0) { $0 + $1 * $1 })
        let recipeMagnitude = sqrt(Double(recipe.tags.count))
            
        guard userMagnitude != 0 && recipeMagnitude != 0 else { return 0 }
        return dot / (userMagnitude * recipeMagnitude)
    }
}

