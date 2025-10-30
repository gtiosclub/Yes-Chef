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
        .navigationTitle(otherUserName)
    }
}
