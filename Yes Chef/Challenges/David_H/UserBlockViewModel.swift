//
//  UsersViewModel.swift
//  Yes Chef
//
//  Created by David Huang on 9/21/25.
//

import Foundation
import FirebaseFirestore

class UserBlockViewModel: ObservableObject {
    @Published var user: User?
    
    init(userId: String) {
        let db = Firestore.firestore()
        
        db.collection("users").addSnapshotListener {(snap, err) in
            if err != nil {
                print("error")
                return
            }
            
            for users in snap!.documentChanges {
                if users.document.documentID == userId {
                    let dbID = users.document.get("id") as! String
                    let dbUsername = users.document.get("name") as! String
                    let dbemail = users.document.get("email") as! String
                    DispatchQueue.main.sync {self.user = User(userId: dbID, username: dbUsername, email: dbemail)}
                }
            }
            
            //let dbID = snap.get("id") as! String
            //let dbUsername = change.document.get("name") as! String
            //let dbemail = document.get("email") as! String
            //DispatchQueue.main.sync {self.user = User(userId: dbID, username: dbUsername, email: dbemail)}
        }
    }
}
