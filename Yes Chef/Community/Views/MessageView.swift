//
//  MessageView.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//

import SwiftUI

struct ChatView: View {
    let chatID: String
    let otherUserID: String?
    
    @State private var messageVM = MessageViewModel()
    @State private var messageText = ""
    @State private var otherUserName = "Chef"
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages List
                messagesList
                
                // Message Input
                messageInput
            }
            .navigationTitle(otherUserName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            if let userID = authVM.currentUser?.userId {
                messageVM.setCurrentUser(userID)
                await messageVM.fetchMessages(for: chatID)
                messageVM.startListeningToMessages(chatID: chatID)
            }
        }
        .onDisappear {
            messageVM.stopListening()
        }
    }
    
    // MARK: - Messages List
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messageVM.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isFromCurrentUser: message.senderID == authVM.currentUser?.userId
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: messageVM.messages.count) { _, _ in
                if let lastMessage = messageVM.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Message Input
    private var messageInput: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    sendMessage()
                }
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(messageText.isEmpty ? .gray : .blue)
            }
            .disabled(messageText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helper Functions
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let otherUserID = otherUserID else { return }
        
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        
        Task {
            await messageVM.sendMessage(
                chatID: chatID,
                receiverID: otherUserID,
                text: text
            )
        }
    }
}

// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    )
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(chatID: "test", otherUserID: "test")
            .environment(AuthenticationVM())
    }
}
