//
//  ChatView.swift
//  Yes Chef
//
//  Created by Jeanzhao on 10/28/25.
//

import SwiftUI

struct ChatView: View {
    @Environment(AuthenticationVM.self) var authVM
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
                                    if message.isRecipe {
                                        chatPostPreview(postId: message.text)
                                            .environment(authVM)
                                    } else {
                                        Text(message.text)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                } else {
                                    if message.isRecipe {
                                        chatPostPreview(postId: message.text)
                                            .environment(authVM)
                                    } else {
                                        Text(message.text)
                                            .padding()
                                            .background(Color.gray.opacity(0.3))
                                            .cornerRadius(12)
                                    }
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


struct chatPostPreview: View {
    @Environment(AuthenticationVM.self) var authVM
    @State private var UVM = UserViewModel()
    @State private var postVM = PostViewModel()
    var postId: String
    @State var username = ""
    @State var recipe: Recipe = Recipe(userId: "", recipeId: "", name: "", ingredients: [], allergens: [], tags: [], steps: [], description: "", prepTime: 0, difficulty: .easy, servingSize: 0, media: ["https://firebasestorage.googleapis.com:443/v0/b/yeschef-d494b.firebasestorage.app/o/recipes%2F566BAD66-8F96-4ED0-8B66-3C1B1E474ED4%2Fmedia_0.jpg?alt=media&token=f3c1c481-0378-4f9b-a467-734fc271fb56"
], chefsNotes: "", likes: 0)
    var body: some View {
        let photoURL = URL(string: recipe.media[0])
        NavigationLink(destination: PostView(recipe: recipe).environment(authVM)) {
            VStack (alignment: .leading, spacing: 6) {
                AsyncImage(url: photoURL) { phase in
                    if let image = phase.image{
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 114, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                    } else{
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(width: 114, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                HStack {
                    Text(recipe.name)
                        .font(.custom("Georgia", size: 11))
                        .foregroundStyle(Color(hex: "#404741"))
                    Spacer()
                }
                HStack {
                    Text(username)
                        .font(.custom("Work Sans", size: 10))
                        .foregroundStyle(Color(hex: "#7C887DF2"))
                    Spacer()
                }
                
            }
            .frame(width: 115)
            .padding(8)
            .background(Color(hex: "#F9F5F2"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onAppear {
                Task{
                    recipe = try await postVM.getRecipeByID(recipeID: postId)
                    if !(recipe.userId.isEmpty) {
                        let posterData = await UVM.getUserInfo(userID: recipe.userId)
                        username = posterData?["username"] as? String ?? "..."
                    }
                }
            }
        }
    }
}

#Preview {
    chatPostPreview(postId: "566BAD66-8F96-4ED0-8B66-3C1B1E474ED4")
}
