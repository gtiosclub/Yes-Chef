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
    var user: User?
    
    func follow(userID: String) async {
        let db = Firestore.firestore()
        let batch = db.batch()
        guard let follower = user else {
            print("No User Detected")
            return
        }
        
        let followingList = db.collection("USERS")
            .document(follower.userId)
            .collection("Following")
        
        let followersList = db.collection("USERS")
            .document(userID)
            .collection("Followers")
            
            
        //Adds batch update to add the userId to the collection of the following user
        batch.setData([:], forDocument: followingList.document(userID))
        
        //Adds batch update to add the followers userId to the collection of the user being followed
        batch.setData([:], forDocument: followersList.document(follower.userId))
        
        do{
            //do this to prevent inconsistency, either both documents get updated or neither do
            try await batch.commit()
            
            //updates the local following
            follower.following.append(userID)
            print("Follower addded successfully!")
            
        } catch {
            print("Error adding document:\(error.localizedDescription)")
        }
        
    }
    
    func getFollows() async {
        
    }
}
