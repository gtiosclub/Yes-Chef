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
    func getAllUsers() async ->[User]{
        var db = Firestore.firestore()
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
            self.users = fetchedUsers
                    
            return fetchedUsers
            } catch {
                print("Error fetching users: \(error)")
                return []
            }
    }
}
