//
//  UserListView.swift
//  Yes Chef
//
//  Created by Jeanzhao on 10/28/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserListView: View {
    @StateObject private var vm = ChatListViewModel()
    @State private var searchVM = SearchViewModel()
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var showDropdown = false
    
    let currentUserId: String = Auth.auth().currentUser?.uid ?? ""
    
    var body: some View {
        VStack(spacing: 0) {
            //Search Bar
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search users...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: searchText) { newValue in
                            Task {
                                await performSearch(query: newValue)
                            }
                        }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                //Dropdown Search Results
                if showDropdown && !searchResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(searchResults) { user in
                                Button(action: {
                                    startChat(with: user)
                                }) {
                                    HStack {
                                        Text(user.username)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding()
                                }
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                }
            }
            .padding(.top)
            
            List {
                            ForEach(vm.chats) { chat in
                                NavigationLink(
                                    destination: ChatView(
                                        vm: ChatViewModel(
                                            chatId: chat.chatId,
                                            currentUserId: currentUserId
                                        ),
                                        otherUserName: chat.otherUserName,
                                        otherUserPhotoURL: chat.otherUserPhotoURL
                                    )
                                ) {
                                    HStack(spacing: 12) {
                                        if let urlString = chat.otherUserPhotoURL,
                                           let url = URL(string: urlString) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.3))
                                            }
                                            .frame(width: 45, height: 45)
                                            .clipShape(Circle())
                                        } else {
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 45, height: 45)
                                        }
                                        
                                        Text(chat.otherUserName)
                                            .font(.headline)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                    .navigationTitle("Messages")
                    .onAppear {
                        vm.fetchUserChats()
                    }
                }
    
    //Perform search
    private func performSearch(query: String) async {
        if query.isEmpty {
            showDropdown = false
            searchResults = []
            return
        }
        let allUsers = await searchVM.getAllUsers()
        let filtered = allUsers.filter {
            $0.username.lowercased().contains(query.lowercased()) &&
            $0.userId != currentUserId
        }
        await MainActor.run {
            searchResults = filtered
            showDropdown = true
        }
    }
    
    //Start chat with searched user
    private func startChat(with user: User) {
        vm.startChat(with: user) { chat in
            if !vm.chats.contains(where: { $0.chatId == chat.chatId }) {
                vm.chats.append(chat)
            }
            searchText = ""
            showDropdown = false
        }
    }
}
