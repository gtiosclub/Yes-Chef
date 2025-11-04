//
//  User.swift
//  Yes Chef
//
//  Created by Nitya Potti on 8/30/25.
//

import Foundation

class User: Equatable, Identifiable, ObservableObject {
    var id: String { userId }
    var userId: String
    var username: String
    var email: String
    var phoneNumber: String?
    var bio: String? //User self introduction
    var password: String?

    
    @Published var profilePhoto: String
    @Published var followers: [String] = []
    @Published var following: [String] = []
    @Published var myRecipes: [String] = []
    @Published var savedRecipes: [String] = []
    @Published var likedRecipes: [String] = []
    @Published var badges: [String] = []


    
    init(userId: String, username: String, email: String, bio: String? = nil, password: String? = nil) {
        self.userId = userId
        self.username = username
        self.email = email
        self.profilePhoto = ""
        self.bio = bio
        self.password = password
    }

    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.userId == rhs.userId && lhs.username == rhs.username && lhs.phoneNumber == rhs.phoneNumber
    }
}
