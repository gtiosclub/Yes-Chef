//
//  Message.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var chatID: String
    var senderID: String
    var receiverID: String
    var text: String
    var timestamp: Date
    var isRead: Bool
    var messageType: MessageType
    
    enum MessageType: String, Codable, CaseIterable {
        case text = "text"
        case image = "image"
        case recipe = "recipe"
    }
    
    init(chatID: String, senderID: String, receiverID: String, text: String, messageType: MessageType = .text) {
        self.chatID = chatID
        self.senderID = senderID
        self.receiverID = receiverID
        self.text = text
        self.timestamp = Date()
        self.isRead = false
        self.messageType = messageType
    }
}
