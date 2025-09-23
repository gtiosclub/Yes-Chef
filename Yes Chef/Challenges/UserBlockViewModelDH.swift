//
//  UsersViewModel.swift
//  Yes Chef
//
//  Created by David Huang on 9/21/25.
//

import Foundation
import FirebaseFirestore

class UserBlockViewModelDH: ObservableObject {
    @Published var user: User?
    
    init(userId: String) {
        let db = Firestore.firestore()
        let doc = db.collection("users").document(userId)
        
        doc.addSnapshotListener {(userdata, err) in
            if err != nil {
                print("error")
                return
            }
            
            guard let userdata = userdata, userdata.exists else {
                print("Document does not exist")
                self.user = nil
                return
            }

            let dbID = userdata.get("id") as! String
            let dbUsername = userdata.get("name") as! String
            let dbemail = userdata.get("email") as! String
            DispatchQueue.main.async {
                self.user = User(userId: dbID, username: dbUsername, email: dbemail)
            }
            
            //let dbID = snap.get("id") as! String
            //let dbUsername = change.document.get("name") as! String
            //let dbemail = document.get("email") as! String
            //DispatchQueue.main.sync {self.user = User(userId: dbID, username: dbUsername, email: dbemail)}
        }
    }
    
    init(mockUser: User) {
        self.user = mockUser
    }
}
