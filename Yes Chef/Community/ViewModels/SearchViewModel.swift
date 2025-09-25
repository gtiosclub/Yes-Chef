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
    func getAllUsers() ->[User]{
        var db = Firestore.firestore()
        //implement to return all users in the database
        return []
    }
}
