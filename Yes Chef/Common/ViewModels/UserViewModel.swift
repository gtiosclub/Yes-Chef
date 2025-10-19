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
}
