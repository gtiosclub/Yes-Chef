//
//  PostView.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//
import SwiftUI


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
    @State private var goToAddRecipe = false
    @State private var liked: Bool = false
    @State private var following: Bool = false
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
                    Image(systemName: "bookmark")
                        .font(Font.title2)
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
                            } else {
                                //need to implement unfollow
                                Task {
                                    await FVM.unfollow(other_userID: recipe.userId, self_userID: authVM.currentUser?.userId ?? "")
                                }
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
            if (authVM.currentUser?.likedRecipes ?? []).contains(recipe.id) {
                liked = true
            } else {
                liked = false
            }
            if (authVM.currentUser?.following ?? []).contains(recipe.userId) {
                following = true
            } else {
                following = false
            }
            
        }
        
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        // Floating Remix Button + Navigation
        .overlay(alignment: .bottomTrailing) {
            NavigationLink("", isActive: $goToAddRecipe) {
                AddRecipeMain(remixRecipe: recipe)
            }
            .hidden()
            ZStack {
                HStack {
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
                    
                    Button {
                        goToAddRecipe = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles").font(.headline)
                            Text("Remix").fontWeight(.semibold)
                        }
                    }
                }
                .fullScreenCover(isPresented: $goToAddRecipe) {
                    AddRecipeMain(remixRecipe: recipe)
                }
            }
        }
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
