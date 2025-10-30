//
//  ChatListViewModel.swift
//  Yes Chef
//
//  Created by Jeanzhao on 10/28/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct ChatPreview: Identifiable {
    var id: String { chatId }
    let chatId: String
    let otherUserId: String
    let otherUserName: String
    let timestamp: Date
}

final class ChatListViewModel: ObservableObject {
    @Published var chats: [ChatPreview] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    //Fetch existing chats
    func fetchUserChats() {
        listener?.remove()
        
        listener = db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching chats: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var fetched: [ChatPreview] = []
                let group = DispatchGroup()
                
                for doc in documents {
                    let data = doc.data()
                    let chatId = doc.documentID
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let participants = data["participants"] as? [String] ?? []
                    
                    // Find other user
                    guard let otherUserId = participants.first(where: { $0 != self.currentUserId }),
                          !otherUserId.isEmpty else {
                        continue
                    }
                    
                    group.enter()
                    self.db.collection("users").document(otherUserId).getDocument { userDoc, _ in
                        let username = userDoc?.data()?["username"] as? String ?? "Unknown"
                        let chat = ChatPreview(
                            chatId: chatId,
                            otherUserId: otherUserId,
                            otherUserName: username,
                            timestamp: timestamp
                        )
                        fetched.append(chat)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.chats = fetched.sorted(by: { $0.timestamp > $1.timestamp })
                }
            }
    }
    
    //Create or open chat
    func startChat(with user: User, completion: @escaping (ChatPreview) -> Void) {
        let chatId = [currentUserId, user.userId].sorted().joined(separator: "_")
        let chatRef = db.collection("chats").document(chatId)
        
        chatRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let snapshot = snapshot, snapshot.exists {
                // Existing chat
                let chat = ChatPreview(
                    chatId: chatId,
                    otherUserId: user.userId,
                    otherUserName: user.username,
                    timestamp: (snapshot.data()?["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                )
                DispatchQueue.main.async {
                    completion(chat)
                }
            } else {
                // New chat document
                chatRef.setData([
                    "participants": [self.currentUserId, user.userId],
                    "timestamp": Timestamp(date: Date())
                ]) { err in
                    if let err = err {
                        print("Error creating chat: \(err)")
                        return
                    }
                    let chat = ChatPreview(
                        chatId: chatId,
                        otherUserId: user.userId,
                        otherUserName: user.username,
                        timestamp: Date()
                    )
                    DispatchQueue.main.async {
                        completion(chat)
                    }
                }
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
