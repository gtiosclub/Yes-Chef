//
//  ChatView.swift
//  Yes Chef
//
//  Created by Jeanzhao on 10/28/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject var vm: ChatViewModel
    var otherUserName: String
    var otherUserPhotoURL: String?
    @State private var typedMessage = ""
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(vm.messages) { message in
                            HStack {
                                if message.senderId == vm.currentUserId {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(12)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: vm.messages.count) { _ in
                    if let lastId = vm.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Message...", text: $typedMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    guard !typedMessage.isEmpty else { return }
                    vm.sendMessage(text: typedMessage)
                    typedMessage = ""
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    if let urlString = otherUserPhotoURL,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 32, height: 32)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            case .failure(_):
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 32, height: 32)
                            @unknown default:
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 32, height: 32)
                            }
                        }
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                    }

                    Text(otherUserName)
                        .font(.headline)
                        .lineLimit(1)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)

    }
}
