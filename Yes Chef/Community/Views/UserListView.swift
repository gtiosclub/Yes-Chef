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
    @Environment(AuthenticationVM.self) var authVM
    @StateObject private var vm = ChatListViewModel()
    @State private var searchVM = SearchViewModel()
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var showDropdown = false
    @Environment(\.dismiss) private var dismiss
    let appBackground = Color(hex: "#FFFDF7")


    
    let currentUserId: String = Auth.auth().currentUser?.uid ?? ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(hex: "#404741"))
                }

                Spacer()

                Text("Chats")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#404741"))
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 25)
            .padding(.bottom, 10)

            VStack {
                HStack {
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search a Chef", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: searchText) { newValue in
                            Task {
                                await performSearch(query: newValue)
                            }
                        }
                }
                .padding(10)
                .background(Color(hex: "#F9F5F2"))
                .cornerRadius(10)
                .padding(.horizontal)
                
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
                    .background(Color(hex: "#fffdf7"))
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
                        ).environment(authVM)
                    ) {

                        HStack(spacing: 12) {

                            if let urlString = chat.otherUserPhotoURL,
                               let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Circle().fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 55, height: 55)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(chat.otherUserName)
                                    .font(.system(size: 18))
                                    .foregroundColor(.primary)

                                Text(subtitle(for: chat))
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }

                            Spacer()
                        }

                        .padding(.vertical, 6)
                    }
                    .listRowBackground(Color(hex: "#FFFDF7")) 
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .background(Color(hex: "#fffdf7").ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            vm.fetchUserChats()
        }
    }
    
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
    
    private func startChat(with user: User) {
        vm.startChat(with: user) { chat in
            if !vm.chats.contains(where: { $0.chatId == chat.chatId }) {
                vm.chats.append(chat)
            }
            searchText = ""
            showDropdown = false
        }
    }
    
    private func subtitle(for chat: ChatPreview) -> String {
        guard let text = chat.lastMessageText, !text.isEmpty else {
            return "No messages yet"
        }

        if chat.lastMessageIsRecipe {
            return "Shared a recipe • \(text)"
        }

        return text
    }

}
