//
//  DMListView.swift
//  Yes Chef
//
//  Created by Aryan on 12/19/24.
//

import SwiftUI

struct DMListView: View {
    @State private var messageVM = MessageViewModel()
    @State private var searchText = ""
    @State private var selectedChat: Chat?
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Search Bar
                    searchBar
                    
                    // Chat List
                    chatListView
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            if let userID = authVM.currentUser?.userId {
                messageVM.setCurrentUser(userID)
                await messageVM.fetchUserChats()
            }
        }
        .sheet(item: $selectedChat) { chat in
            if let chatID = chat.id {
                ChatView2(chatID: chatID, otherUserID: getOtherUserID(from: chat))
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("Chats")
                .font(.custom("Georgia", size: 24))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#453736"))
            
            Spacer()
            
            // Invisible spacer to center the title
            Image(systemName: "arrow.left")
                .font(.title2)
                .opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 16)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 12)
            
            TextField("Search a chef", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 12)
                .padding(.trailing, 12)
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Chat List
    private var chatListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredChats) { chat in
                    ChatRowView(chat: chat) {
                        selectedChat = chat
                    }
                    
                    if chat.id != filteredChats.last?.id {
                        Divider()
                            .padding(.leading, 80)
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    // MARK: - Computed Properties
    private var filteredChats: [Chat] {
        if searchText.isEmpty {
            return messageVM.chats
        } else {
            return messageVM.chats.filter { chat in
                // This would need to filter by the other user's name
                // For now, just return all chats
                true
            }
        }
    }
    
    private func getOtherUserID(from chat: Chat) -> String? {
        guard let currentUserID = authVM.currentUser?.userId else { return nil }
        return chat.participants.first { $0 != currentUserID }
    }
}

// MARK: - Chat Row View
struct ChatRowView: View {
    let chat: Chat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile Picture
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
                
                // Chat Info
                VStack(alignment: .leading, spacing: 4) {
                    // Name
                    Text("Chef Name") // This would be the other user's name
                        .font(.headline)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    // Last Message
                    HStack {
                        /*
                        if chat.messageType == .recipe {
                            Image(systemName: "book.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }*/
                        
                        Text(chat.lastMessage ?? "Most recent chat")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Timestamp
                Text(formatTimestamp(chat.lastMessageTimestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTimestamp(_ date: Date?) -> String {
        guard let date = date else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct DMListView_Previews: PreviewProvider {
    static var previews: some View {
        DMListView()
            .environment(AuthenticationVM())
    }
}

