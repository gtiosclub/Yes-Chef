//
//  Chat.swift
//  Yes Chef
//
//  Created by Aryan on 12/19/24.
//

import Foundation
import FirebaseFirestore

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String] // Array of user IDs
    var lastMessage: String?
    var lastMessageTimestamp: Date?
    var lastMessageSenderID: String?
    var createdDate: Date
    var updatedDate: Date
    
    // Computed properties for display
    var otherParticipantID: String? {
        // This would need to be set based on current user
        return participants.first
    }
    
    init(participants: [String], lastMessage: String? = nil, lastMessageTimestamp: Date? = nil, lastMessageSenderID: String? = nil) {
        self.participants = participants
        self.lastMessage = lastMessage
        self.lastMessageTimestamp = lastMessageTimestamp
        self.lastMessageSenderID = lastMessageSenderID
        self.createdDate = Date()
        self.updatedDate = Date()
    }
}

