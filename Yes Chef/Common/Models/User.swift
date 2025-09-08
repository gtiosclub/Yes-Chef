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
    
    init(userId: String, username: String, email: String) {
        self.username = username
        self.userId = userId
        self.email = email
        self.phoneNumber = phoneNumber
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.userId == rhs.userId && lhs.username == rhs.username && lhs.phoneNumber == rhs.phoneNumber
    }
}
