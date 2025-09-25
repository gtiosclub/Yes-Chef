//
//  Message.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//
import SwiftUI
class Message {
    var senderID: String
    var receiverID: String
    var text: String
    var timestamp: Date?
    
    init(senderID: String, receiverID: String, text: String, timestamp: Date?) {
        self.senderID = senderID
        self.receiverID = receiverID
        self.text = text
        self.timestamp = timestamp
    }
}
