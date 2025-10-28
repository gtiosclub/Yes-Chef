//
//  MessageViewModel.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//

import Foundation
import Observation
import FirebaseFirestore

@Observable class MessageViewModel {
    var chats: [Chat] = []
    var messages: [Message] = []
    var isLoading = false
    var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var currentUserID: String?
    
    func setCurrentUser(_ userID: String) {
        self.currentUserID = userID
    }
    
    // MARK: - Chat Management
    
    func fetchUserChats() async {
        guard let userID = currentUserID else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("chats")
                .whereField("participants", arrayContains: userID)
                .order(by: "updatedDate", descending: true)
                .getDocuments()
            
            chats = snapshot.documents.compactMap { document in
                try? document.data(as: Chat.self)
            }
        } catch {
            errorMessage = "Failed to fetch chats: \(error.localizedDescription)"
            print("Error fetching chats: \(error)")
        }
        
        isLoading = false
    }
    
    func createChat(with userID: String) async -> String? {
        guard let currentUserID = currentUserID else { return nil }
        
        // Check if chat already exists
        let existingChat = chats.first { chat in
            chat.participants.contains(userID) && chat.participants.contains(currentUserID)
        }
        
        if let existingChat = existingChat {
            return existingChat.id
        }
        
        // Create new chat
        let newChat = Chat(participants: [currentUserID, userID])
        
        do {
            let docRef = try db.collection("chats").addDocument(from: newChat)
            await fetchUserChats() // Refresh the list
            return docRef.documentID
        } catch {
            errorMessage = "Failed to create chat: \(error.localizedDescription)"
            print("Error creating chat: \(error)")
            return nil
        }
    }
    
    // MARK: - Message Management
    
    func fetchMessages(for chatID: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("messages")
                .whereField("chatID", isEqualTo: chatID)
                .order(by: "timestamp", descending: false)
                .getDocuments()
            
            messages = snapshot.documents.compactMap { document in
                try? document.data(as: Message.self)
            }
        } catch {
            errorMessage = "Failed to fetch messages: \(error.localizedDescription)"
            print("Error fetching messages: \(error)")
        }
        
        isLoading = false
    }
    
    func sendMessage(chatID: String, receiverID: String, text: String, messageType: Message.MessageType = .text) async {
        guard let currentUserID = currentUserID else { return }
        
        let message = Message(
            chatID: chatID,
            senderID: currentUserID,
            receiverID: receiverID,
            text: text,
            messageType: messageType
        )
        
        do {
            try db.collection("messages").addDocument(from: message)
            
            // Update chat's last message
            try await db.collection("chats").document(chatID).updateData([
                "lastMessage": text,
                "lastMessageTimestamp": message.timestamp,
                "lastMessageSenderID": currentUserID,
                "updatedDate": message.timestamp
            ])
            
            // Refresh messages
            await fetchMessages(for: chatID)
            await fetchUserChats() // Refresh chat list
            
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
            print("Error sending message: \(error)")
        }
    }
    
    // MARK: - Real-time Updates
    
    func startListeningToMessages(chatID: String) {
        db.collection("messages")
            .whereField("chatID", isEqualTo: chatID)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = "Failed to listen to messages: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.messages = documents.compactMap { document in
                    try? document.data(as: Message.self)
                }
            }
    }
    
    func stopListening() {
        // In a real implementation, you'd store the listener and remove it
        // For now, this is a placeholder
    }
}
