//
//  SearchViewModel.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//
import Foundation
import Observation
import FirebaseFirestore

@Observable class SearchViewModel {
    var users: [User] = []
    var usernames: [String] = []
    
    func getAllUsers() async ->[User]{
        let db = Firestore.firestore()
        //return all users in the database
        do {
            // Fetch all documents from "users" collection
            let snapshot = try await Firebase.db.collection("users").getDocuments()
                    
            // Map documents into User objects
            let fetchedUsers = snapshot.documents.map { doc -> User in
                let data = doc.data()
                return User(
                    userId: data["userId"] as? String ?? "",
                    username: data["username"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    bio: data["bio"] as? String
                )
            }
                    
            // Update the local users array
            await MainActor.run {
                self.users = fetchedUsers
            }
                    
            return fetchedUsers
            } catch {
                print("Error fetching users: \(error)")
                return []
            }
    }
    func getAllUsernames() async -> [String]{
            do {
                let snapshot = try await Firebase.db.collection("users").getDocuments()
                
                let fetchedUsernames = snapshot.documents.compactMap { doc -> String? in
                    let data = doc.data()
                    return data["username"] as? String
                }
                
                await MainActor.run {
                    self.usernames = fetchedUsernames
                }
                
                return fetchedUsernames
            } catch {
                print("Error fetching usernames: \(error.localizedDescription)")
                return []
            }
        }
}


// MARK: Email and Password functions

func updateEmail(userId: String, oldEmail: String, newEmail: String) async throws {
    let db = Firestore.firestore()
    let userDoc = db.collection("users").document(userId)
    
    // Fetch current email
    let snapshot = try await userDoc.getDocument()
    guard let data = snapshot.data(),
          let currentEmail = data["email"] as? String else {
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
    }
    
    // Check old email
    guard currentEmail == oldEmail else {
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Old email is incorrect"])
    }
    
    // Update email
    try await userDoc.updateData(["email": newEmail])
    print("Email updated successfully")
}

func updatePassword(userId: String, oldPassword: String, newPassword: String) async throws {
    let db = Firestore.firestore()
    let userDoc = db.collection("users").document(userId)
    
    // Fetch current password
    let snapshot = try await userDoc.getDocument()
    guard let data = snapshot.data(),
          let currentPassword = data["password"] as? String else {
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
    }
    
    // Check old password
    guard currentPassword == oldPassword else {
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Old password is incorrect"])
    }
    
    // Update password
    try await userDoc.updateData(["password": newPassword])
    print("Password updated successfully")
}
