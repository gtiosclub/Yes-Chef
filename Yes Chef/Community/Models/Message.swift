//
//  Message.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//


import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var timestamp: Timestamp
}

