//
//  PostView.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//
import SwiftUI
import FirebaseAuth


let screen = UIScreen.main.bounds

struct PostView: View {
    var recipe: Recipe
    
    @Environment(\.dismiss) private var dismiss
    @State private var UVM = UserViewModel()
    @State private var postVM = PostViewModel()
    @State private var mediaItem: Int? = 0
    @Environment(AuthenticationVM.self) var authVM
    //@State var remixTree: RemixTree
    @State private var username: String = ""
    @State private var profilePhoto: String = ""
    @State private var FVM = FollowViewModel()
    
    @State private var liked: Bool = false
    @State private var following: Bool = false
    @State private var saved: Bool = false

    @State private var goToAddRecipe = false
    @State private var showComments = false
    // Eesh New Edit: Add state for navigating to remix tree view
    @State private var goToRemixTree = false
    // End of Eesh New Edit
    
    var body: some View {
        ScrollView{
            VStack(spacing: 6 ){
                HStack(spacing: 6 ){
                    
                    //Back Button
                    Button(action: {dismiss()}){
                        Image(systemName: "chevron.backward").font(Font.title2)
                    }
                    
                    //Divider().padding(.horizontal, 15).background(Color.clear)
                    //Title
                    Spacer()
                    Text(recipe.name).font(Font.title)
                    //Bookmark Button
                    //Divider().padding(.horizontal, 5)
                    Spacer()
                    Button {
                        Task {
                            if !saved {
                                await authVM.saveRecipe(recipeId: recipe.id)
                                authVM.currentUser?.savedRecipes.append(recipe.id)
                                saved = true
                            } else {
                                await authVM.unsaveRecipe(recipeId: recipe.id)
                                authVM.currentUser?.savedRecipes.removeAll { $0 == recipe.id }
                                saved = false
                            }
                        }
                    } label: {
                        Image(systemName: saved ? "bookmark.fill" : "bookmark")
                            .font(Font.title2)
                    }
                    //... Button
                    Image(systemName: "ellipsis")
                        .font(Font.title2)
                        .frame(alignment: .trailing)
                    Button {
                        RemixTree.deleteNodeFirebase(nodeId: recipe.recipeId)
                    } label: {
                        Image(systemName: "trash")
                            .font(Font.title2)
                            .frame(alignment: .trailing)
                            .foregroundStyle(.black)
                    }
                    
                }
                .padding(.bottom, screen.width/50)
                
                HStack{
                    
                    //Poster Profile Pic
                    let photoURL = URL(string: profilePhoto)
                    AsyncImage(url: photoURL) { phase in
                        if let image = phase.image{
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 40, height: 40)
                            
                        } else{
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 40, height: 40)
                        }
                    }
                    
                    //Poster Username
                    Text(username)
                    
                    Spacer()
                    
                    //Follow Button
                    if (!(recipe.userId == authVM.currentUser?.userId ?? "")){
                        
                        Button(){
                            if (!following) {
                                Task {
                                    await FVM.follow(other_userID: recipe.userId, self_userID: authVM.currentUser?.userId ?? "")
                                }
                                authVM.currentUser?.following.append(recipe.userId)
                                following = true
                                print("Followed, \(following)")
                            } else {
                                //need to implement unfollow
                                Task {
                                    await FVM.unfollow(other_userID: recipe.userId, self_userID: authVM.currentUser?.userId ?? "")
                                }
                                authVM.currentUser?.following.removeAll { $0 == recipe.userId }
                                following = false
                            }
                            
                        } label: {
                            if (!following) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray3))
                                        .frame(width: 80, height: 30)
                                    Text("Follow").foregroundColor(Color.black)
                                }
                            } else {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray3))
                                        .frame(width: 80, height: 30)
                                    Text("Following").foregroundColor(Color.black)
                                }
                            }
                        }
                    }
                }
                
                //Recipe Pics
                ScrollView(.horizontal){
                    HStack{
                        ForEach(Array(recipe.media.enumerated()), id: \.offset){ index, media in
                            
                            AsyncImage(url: URL(string: media)) { phase in
                                if let image = phase.image{
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: screen.width/1.2, height: screen.height/2.5)
                                        .id(index)
                                    
                                } else{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray3))
                                        .frame(width: screen.width/1.2, height: screen.height/2.5)
                                        .id(index)
                                }
                            }
                            
                        }
                    }
                    .scrollTargetLayout()
                    //TODO scroll targeting needs iOS 17 adapt this so it doesn't cause trouble
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $mediaItem)
                
                //Scroll Dot Indicator
                HStack(spacing: 1){
                    ForEach(Array(recipe.media.enumerated()), id: \.offset){ index, media in
                        if let mediaNum = mediaItem{
                            if index == mediaNum{
                                //Text("\(mediaNum)")
                                Text("•")
                                    .font(Font.largeTitle)
                                    .foregroundColor(Color.black)
                            }
                            else{
                                Text("•")
                                    .font(Font.largeTitle)
                                    .foregroundColor(Color.gray)
                                
                            }
                        }
                        
                    }
                }
                
                //Recipe Description
                Text(recipe.description).font(Font.body)
                
                HStack(){
                    let space = screen.width/75
                    //Difficulty Icon
                    Image(systemName: "flame.fill")
                    Text(LocalizedStringKey(recipe.difficulty.id.prefix(1).uppercased() + recipe.difficulty.id.dropFirst()))
                        .padding(.trailing, space)
                    
                    //Time+Icon
                    Image(systemName: "clock")
                    Text("\(recipe.prepTime) minutes")
                        .padding(.trailing, space)
                    
                    //Serving Size
                    Image(systemName: "person.fill")
                    
                    //TODO recipe has no serving size variable so this will have to be adapted
                    Text("Serves \(recipe.servingSize)").lineLimit(1)
                    Spacer()
                    
                    
                }.padding(.vertical,10)
                
                //Ingredients
                VStack( alignment: .leading, spacing: 2){
                    Text("Ingredients").font(Font.title).padding(.vertical, screen.height/100)
                    //                    ForEach (recipe.ingredients, id: \.self){ each in
                    //                        BulletPoint(text: each, type: 1, num: 0).frame(maxHeight: 25)
                    //                    }
                    
                    Text("Instructions")
                        .font(Font.title)
                        .padding(.vertical, screen.height/100)
                    //Instruction Steps
                    ForEach (Array(recipe.steps.enumerated()), id: \.offset){ index, each in
                        BulletPoint(text: each, type: 2, num: index)
                    }
                }
                
                ScrollView(.horizontal){
                    HStack{
                        //Tags
                        ForEach(recipe.tags, id: \.self){ tag in
                            Text(tag)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray5))
                                )
                                .foregroundColor(.black)
                        }
                    }
                }.padding(.top, screen.height/50)
                
                CarouselView(recipe: recipe)
            }
            .padding(15)
            .padding(.bottom, 80)
        }
        .task{
            if !(recipe.userId.isEmpty) {
                let posterData = await UVM.getUserInfo(userID: recipe.userId)
                profilePhoto = posterData?["profilePhoto"] as? String ?? ""
                username = posterData?["username"] as? String ?? "..."
            }
        }
        .onAppear {
            liked = (authVM.currentUser?.likedRecipes ?? []).contains(recipe.id)
            following = (authVM.currentUser?.following ?? []).contains(recipe.userId)
            saved = (authVM.currentUser?.savedRecipes ?? []).contains(recipe.id)
            Task {
                let user = authVM.currentUser ?? User(userId: "", username: "", email: "", bio: "")
                await UVM.updateSuggestionProfile(userID: user.userId, suggestionProfile: &user.suggestionProfile, recipe: recipe, interaction: "view")
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToAddRecipe) {
            AddRecipeMain(remixRecipe: recipe)
                .environment(authVM)
        }
        .navigationDestination(isPresented: $goToRemixTree) {
            RemixTreeView(nodeID: recipe.recipeId)
                .environment(authVM)
        }
        // Eesh New Edit: Added Remix Tree button alongside existing Remix button
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 12) {
                // Comment Button
                Button {
                    showComments = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "message").font(.headline)
                    }
                    .background(Capsule().fill(Color.black))
                    .foregroundColor(.white)
                    .shadow(radius: 4, y: 2)
                    .padding(.bottom, 16)
                }
                .sheet(isPresented: $showComments) {
                    CommentsSheet(recipeID: recipe.recipeId)
                }
                //remix tree
                Button {
                    goToRemixTree = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "tree").font(.headline)
                        Text("Remix Tree").fontWeight(.semibold)
                    }
                    .background(Capsule().fill(Color.blue))
                    .foregroundColor(.white)
                    .shadow(radius: 4, y: 2)
                }
                .accessibilityLabel("View remix tree")
                    
                // Original Remix Button
                Button {
                    goToAddRecipe = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles").font(.headline)
                        Text("Remix").fontWeight(.semibold)
                    }
                    .background(Capsule().fill(Color.black))
                    .foregroundColor(.white)
                    .shadow(radius: 4, y: 2)
                }
                //like
                likeButton(liked: liked, recipe: recipe, authVM: authVM, postVM: postVM, UVM: UVM)
            }
        }
        .navigationDestination(isPresented: $goToAddRecipe) {
            AddRecipeMain(remixRecipe: recipe)
                .environment(authVM)
        }
        .navigationDestination(isPresented: $goToRemixTree) {
            RemixTreeView(nodeID: recipe.recipeId)
                .environment(authVM)
        }
    }
}
struct likeButton: View {
    @State var liked: Bool
    var recipe: Recipe
    @State var authVM: AuthenticationVM
    @State var postVM: PostViewModel
    @State var UVM: UserViewModel
    var body: some View {
        HStack {
            //likes and like button
            Text(String(recipe.likes))
            Button {
                if (!liked) {
                    Task {
                        try await postVM.likePost(recipeId: recipe.id)
                        try await UVM.like(recipeID: recipe.id, userID: authVM.currentUser?.id ?? "")
                    }
                    recipe.likes += 1
                    authVM.currentUser?.likedRecipes.append(recipe.id)
                    liked = true
                    Task {
                        let user = authVM.currentUser ?? User(userId: "", username: "", email: "", bio: "")
                        await UVM.updateSuggestionProfile(userID: user.userId, suggestionProfile: &user.suggestionProfile, recipe: recipe, interaction: "like")
                    }
                } else {
                    Task {
                        try await postVM.unlikePost(recipeId: recipe.id)
                        try await UVM.unlike(recipeID: recipe.id, userID: authVM.currentUser?.id ?? "")
                    }
                    recipe.likes -= 1
                    authVM.currentUser?.likedRecipes.removeAll { $0 == recipe.id }
                    liked = false
                }
            } label : {
                if (!liked) {
                    Image(systemName: "heart").foregroundColor(.black)
                } else {
                    Image(systemName: "heart.fill").foregroundColor(.red)
                }
                
            }.frame(width: 20, height: 20)
        }
        .accessibilityLabel("Like button")
    }
}
struct CommentsSheet: View {
    @StateObject private var viewModel = CommentsViewModel()
    @State private var UVM = UserViewModel()
    @State private var currentUsername: String = ""
    let recipeID: String

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 6)
                .padding(.top, 8)

            Text("Comments")
                .font(.headline)
                .padding(.vertical, 8)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.comments) { comment in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(comment.poster)
                                    .font(.subheadline)
                                    .bold()
                                
                                Text(comment.text)
                                    .font(.body)
                                
                                if let timestamp = comment.timestamp {
                                    Text(timestamp, style: .relative)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            Image(systemName: "heart")
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }


            Divider()

            HStack {
                TextField("Add comment...", text: $viewModel.newCommentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Post") {
                    viewModel.postComment(for: recipeID, poster: currentUsername)
                    viewModel.fetchComments(for: recipeID)
                }
                .foregroundColor(.blue)
            }
            .padding()
        }
        .onAppear {
            Task {
                Task {
                    if let userData = await UVM.getCurrentUserInfo() {
                        currentUsername = userData["username"] as? String ?? "Unknown"
                    }
                    viewModel.fetchComments(for: recipeID)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}


struct BulletPoint: View {
    var text: String
    let type: Int
    var num: Int
    
    var body: some View {
        HStack{
            if(type == 1){
                Text("•").font(Font.largeTitle)
            } else if (type == 2){
                if num <= 9{
                    Text("0\(num)").font(Font.title2).padding(.trailing, screen.width/75)
                }
            }
            Text(text).font(Font.body)
                .padding(.bottom, screen.height/100)
            Spacer()
        }
    }
}





#Preview {
    let rec = Recipe(
        userId: "zvUtxNaS4FRTC1522AsZLxCXl5s1",
        recipeId: "recipeID",
        name: "Chaffle",
        ingredients: [
            Ingredient(name: "egg", quantity: 1, unit: "", preparation: ""),
            Ingredient(name: "flour", quantity: 3, unit: "cups", preparation: ""),
            Ingredient(name: "butter", quantity: 1, unit: "teaspoon", preparation: "")
        ],
        allergens: [""],
        tags: ["american", "keto", "gluten free"],
        steps: [
            "Preheat a waffle iron to medium-high. Whisk the eggs in a large bowl until well beaten and smooth.",
            "Coat the waffle iron with nonstick cooking spray, then ladle a heaping 1/4 cup of batter into each section.",
            "Top each chaffle with a pat of butter and drizzle with maple syrup."
        ],
        description: "A chaffle is a low-carb, cheese-and-egg-based waffle that's taken the keto world by storm, thanks to its fluffy texture and crispy edges.",
        prepTime: 120,
        difficulty: .easy,
        servingSize: 1,
        media: [
            "https://www.themerchantbaker.com/wp-content/uploads/2019/10/Basic-Chaffles-REV-Total-3-480x480.jpg",
            "https://thebestketorecipes.com/wp-content/uploads/2022/01/Easy-Basic-Chaffle-Recipe-Easy-Keto-Chaffle-5.jpg",
            ""
        ],
        chefsNotes: "String",
        likes: 0
    )
    PostView(recipe: rec)
}
