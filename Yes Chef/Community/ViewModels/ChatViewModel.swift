//
//  ChatViewModel.swift
//  Yes Chef
//
//  Created by Jeanzhao on 10/28/25.
//

import Firebase
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    let chatId: String
    let currentUserId: String
    
    init(chatId: String, currentUserId: String) {
        self.chatId = chatId
        self.currentUserId = currentUserId
        fetchMessages()
    }
    
    func fetchMessages() {
        listener = db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { try? $0.data(as: Message.self) }
            }
    }
    
    func sendMessage(text: String, isRecipe: Bool = false) {
        let message = Message(senderId: currentUserId, text: text, timestamp: Timestamp(), isRecipe: isRecipe)
        do {
            _ = try db.collection("chats").document(chatId)
                .collection("messages")
                .addDocument(from: message)
        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    deinit {
        listener?.remove()
    }
}
