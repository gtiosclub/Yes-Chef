//
//  UserViewModel.swift
//  Yes Chef
//
//  Created by Hawthorne Brown on 10/9/25.
//

import Foundation
import Observation
import FirebaseAuth
import FirebaseFirestore

class UserViewModel: ObservableObject {
    
    func getUserInfo(userID: String) async -> [String: Any]? {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userID)
        
        do {
            let doc = try await docRef.getDocument()
            if doc.exists {
                return doc.data()
            }
        } catch {
            print("Error getting document: \(error)")
        }
        
        return nil
    }
    
    func getCurrentUserInfo() async -> [String: Any]? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged-in user")
            return nil
        }
        return await getUserInfo(userID: uid)
    }
}
