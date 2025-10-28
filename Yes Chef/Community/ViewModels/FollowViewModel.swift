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
        let db = Firestore.firestore()
        let batch = db.batch()
        print(self_userID)
        let followingList = db.collection("USERS")
            .document(self_userID)
            .collection("Following")
        
        let followersList = db.collection("USERS")
            .document(other_userID)
            .collection("Followers")
        
            
        //Adds batch update to add the userId to the collection of the following user
        batch.setData([:], forDocument: followingList.document(other_userID))
        
        //Adds batch update to add the followers userId to the collection of the user being followed
        batch.setData([:], forDocument: followersList.document(self_userID))
        
        do{
            //do this to prevent inconsistency, either both documents get updated or neither do
            try await batch.commit()
            
            //updates the local following
            print("Follower addded successfully!")
            
        } catch {
            print("Error adding document:\(error.localizedDescription)")
        }
        
    }
    
    func getFollows() async {
        
    }
}
