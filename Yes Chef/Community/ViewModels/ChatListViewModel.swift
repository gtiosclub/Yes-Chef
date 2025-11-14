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
    let otherUserPhotoURL: String?
    let timestamp: Date
    let lastMessageText: String?
    let lastMessageIsRecipe: Bool
}

final class ChatListViewModel: ObservableObject {
    @Published var chats: [ChatPreview] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
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
                    let chatTimestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let participants = data["participants"] as? [String] ?? []
                    
                    guard let otherUserId = participants.first(where: { $0 != self.currentUserId }) else {
                        continue
                    }
                    
                    group.enter()
                    self.db.collection("users").document(otherUserId).getDocument { userDoc, _ in
                        
                        let username = userDoc?.data()?["username"] as? String ?? "Unknown"
                        let profilePhoto = userDoc?.data()?["profilePhoto"] as? String
                        
                        self.db.collection("chats")
                            .document(chatId)
                            .collection("messages")
                            .order(by: "timestamp", descending: true)
                            .limit(to: 1)
                            .getDocuments { snapshot, _ in

                                guard let msg = snapshot?.documents.first else {
                                    let chat = ChatPreview(
                                        chatId: chatId,
                                        otherUserId: otherUserId,
                                        otherUserName: username,
                                        otherUserPhotoURL: profilePhoto,
                                        timestamp: chatTimestamp,
                                        lastMessageText: "No messages yet",
                                        lastMessageIsRecipe: false
                                    )
                                    
                                    fetched.append(chat)
                                    group.leave()
                                    return
                                }

                                var lastText: String? = msg["text"] as? String
                                var lastIsRecipe = false
                                var lastTimestamp = msg["timestamp"] as? Timestamp == nil
                                    ? chatTimestamp
                                    : (msg["timestamp"] as! Timestamp).dateValue()

                                if let typeString = msg["messageType"] as? String, typeString == "recipe" {
                                    lastIsRecipe = true
                                } else if let flag = msg["isRecipe"] as? Bool {
                                    lastIsRecipe = flag
                                }

                                if lastIsRecipe, let recipeID = lastText {
                                    group.enter()
                                    self.db.collection("RECIPES")
                                        .document(recipeID)
                                        .getDocument { doc, _ in
                                            lastText = doc?.data()?["name"] as? String ?? "Shared a recipe"
                                            
                                            fetched.append(ChatPreview(
                                                chatId: chatId,
                                                otherUserId: otherUserId,
                                                otherUserName: username,
                                                otherUserPhotoURL: profilePhoto,
                                                timestamp: lastTimestamp,
                                                lastMessageText: lastText,
                                                lastMessageIsRecipe: true
                                            ))
                                            group.leave()
                                        }
                                    
                                    group.leave()
                                    return
                                }

                                fetched.append(ChatPreview(
                                    chatId: chatId,
                                    otherUserId: otherUserId,
                                    otherUserName: username,
                                    otherUserPhotoURL: profilePhoto,
                                    timestamp: lastTimestamp,
                                    lastMessageText: lastText,
                                    lastMessageIsRecipe: false
                                ))

                                group.leave()
                            }


                    }
                }
                
                group.notify(queue: .main) {
                    self.chats = fetched.sorted(by: { $0.timestamp > $1.timestamp })
                }
            }
    }
    
    
    func startChat(with user: User, completion: @escaping (ChatPreview) -> Void) {
        let chatId = [currentUserId, user.userId].sorted().joined(separator: "_")
        let chatRef = db.collection("chats").document(chatId)
        
        chatRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            let now = Date()
            
            if let snapshot = snapshot, snapshot.exists {
                let preview = ChatPreview(
                    chatId: chatId,
                    otherUserId: user.userId,
                    otherUserName: user.username,
                    otherUserPhotoURL: user.profilePhoto,
                    timestamp: (snapshot.data()?["timestamp"] as? Timestamp)?.dateValue() ?? now,
                    lastMessageText: nil,
                    lastMessageIsRecipe: false
                )
                DispatchQueue.main.async { completion(preview) }
            } else {
                chatRef.setData([
                    "participants": [self.currentUserId, user.userId],
                    "timestamp": Timestamp(date: now)
                ]) { err in
                    if let err = err {
                        print("Error creating chat: \(err)")
                        return
                    }
                    
                    let preview = ChatPreview(
                        chatId: chatId,
                        otherUserId: user.userId,
                        otherUserName: user.username,
                        otherUserPhotoURL: user.profilePhoto,
                        timestamp: now,
                        lastMessageText: nil,
                        lastMessageIsRecipe: false
                    )
                    
                    DispatchQueue.main.async { completion(preview) }
                }
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
