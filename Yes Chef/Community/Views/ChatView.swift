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
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
        VStack(spacing: 0) {

            HStack(spacing: 12) {

                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .font(.title2)
                        .foregroundColor(.black)
                }

                if let urlString = otherUserPhotoURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        if let img = phase.image {
                            img.resizable()
                                .scaledToFill()
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                }

                Text(otherUserName)
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(Color(hex: "#404741"))

                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(vm.messages) { message in
                            HStack(alignment: .bottom, spacing: 8) {

                                if message.senderId != vm.currentUserId {
                                    VStack(alignment: .leading, spacing: 4) {
                                        if message.isRecipe {
                                            chatPostPreview(postId: message.text)
                                                .environment(authVM)
                                        } else {
                                            Text(message.text)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 10)
                                                .background(Color(hex: "#E8E3D9"))
                                                .foregroundColor(Color(hex: "#404741"))
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                        }
                                    }
                                    Spacer()
                                }

                                if message.senderId == vm.currentUserId {
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        if message.isRecipe {
                                            chatPostPreview(postId: message.text)
                                                .environment(authVM)
                                        } else {
                                            Text(message.text)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 10)
                                                .background(Color(hex: "#F4A261"))
                                                .foregroundColor(.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 10)

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
            
            HStack(spacing: 10) {

                TextField("Message...", text: $typedMessage)
                    .padding(12)
                    .background(Color(hex: "#F9F5F2"))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                Button {
                    guard !typedMessage.isEmpty else { return }
                    vm.sendMessage(text: typedMessage)
                    typedMessage = ""
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color(hex: "#F4A261"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(hex: "#FFFDF7"))
        }

        .navigationBarHidden(true)
        .background(Color(hex: "#fffdf7").ignoresSafeArea())

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
