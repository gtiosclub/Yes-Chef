import SwiftUI

struct ProfileView: View {
    @State private var selectedTab = 0
    @State private var isFollowing = false
    @State private var postVM = PostViewModel()
    @Environment(AuthenticationVM.self) var authVM
    @State private var showingMessage = false
    @State private var messageVM = MessageViewModel()
    @State private var UVM = UserViewModel()
    @State private var username: String = ""
    @State private var profilePhoto: String = ""
    @State private var showingEditProfile = false
    

    @State var user: User
    // Simple boolean to toggle between own profile vs other's profile for UI demo
    let isOwnProfile: Bool
    
    init(user: User, isOwnProfile: Bool = false) {
        self.user = user;
        self.isOwnProfile = isOwnProfile;
    }
    //let user: User = User(userId: "test", username: "test", email: "test", bio: "test")
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // Header
                //headerView
                
                // Profile Info
                profileInfoSection
                
                // Stats
                statsSection
                
                // Action Button
                actionButton
                
                // Tab Selection
                if(isOwnProfile){
                    tabSelection
                }
                
                if selectedTab == 0 {
                    if postVM.selfRecipes.isEmpty {
                        Text("No posts yet")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        contentGrid(recipes: postVM.selfRecipes)
                    }
                } else {
                    if authVM.savedRecipes.isEmpty {
                        Text("No saved recipes yet!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        contentGrid(recipes: authVM.savedRecipes)
                    }
                }
            }
            .task {
                do {
                    try await postVM.fetchUserPosts(userID: user.userId)
                    if !(user.userId.isEmpty) {
                        let posterData = await UVM.getUserInfo(userID: user.userId)
                        profilePhoto = posterData?["profilePhoto"] as? String ?? ""
                    }
                    self.user = await UVM.updateUser(userID: user.userId)
                } catch {
                    print("Failed to fetch recipes: \(error)")
                }
            }
            .onChange(of: selectedTab) { newTab in
                if newTab == 1 {
                    Task {
                        await authVM.fetchSavedRecipes()
                    }
                }
                
            }

        }
        .background(Color(hex: "#fffdf7"))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            if isOwnProfile {
                Button(action: {}) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Profile Info
    private var profileInfoSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    if isOwnProfile {
                        Spacer()
                        Button{
                            print("SETTINGS")
                        }label:{
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                }
            }
            
            // Profile Image
            let photoURL = URL(string: profilePhoto)
            
            AsyncImage(url: photoURL) { phase in
                if let image = phase.image{
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 120, height: 120)
                        
                } else{
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                }
            }
            // Display Name
            Text(user.username)
                .font(.title2)
                .fontWeight(.semibold)
            
            // Bio
            Text(user.bio ?? "")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        //.padding(.top, 20)
    }
    
    // MARK: - Stats
    private var statsSection: some View {
        HStack(spacing: 40) {
            VStack(spacing: 4) {
                Text("\(user.followers.count)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Followers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 4) {
                Text("\(user.following.count)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Following")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 4) {
                Text("\(postVM.selfRecipes.count)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Recipes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Action Button
    @ViewBuilder
    private var actionButton: some View {
        if(isOwnProfile){
             Button{
                 showingEditProfile = true
            } label: {
                Text("Edit")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor( .white)
                    .frame(width: 120, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.orange.opacity(0.83))
                    )
            }
            .padding(.bottom, 15)
            .sheet(isPresented: $showingEditProfile) {
                        EditProfileView(user: user)
                    }
            
        } else {
             HStack{
                Button{
                    isFollowing.toggle()
                } label: {
                    Text((isFollowing ? "Following" : "Follow"))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isOwnProfile ? .black : (isFollowing ? .black : .white))
                        .frame(width: 120, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.orange.opacity(0.83))
                        )
                } .padding(.bottom, 15)
            
                
                Button{
                    if !isOwnProfile {
                        isFollowing.toggle()
                    }
                } label: {
                    Text("Message")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isOwnProfile ? .black : (isFollowing ? .black : .white))
                        .frame(width: 120, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.orange.opacity(0.83))
                        )
                }
                .padding(.bottom, 15)
            }
        }
    }
    
    // MARK: - Tab Selection
    private var tabSelection: some View {
        ZStack(alignment: .bottomLeading){
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "fffdf7"))
                .frame(height: 56)
                .background(Color(hex: "fffdf7"))
            
            
            HStack(spacing: 0) {
                
                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 8) {
                        Text("My Posts")
                            .font(.body)
                            //.fontWeight(selectedTab == 0 ? .semibold : .regular)
                            .foregroundColor(.black)
                        
                    }
                }
                .padding(.bottom , 10)
                .frame(maxWidth: .infinity)
                .zIndex(selectedTab == 0 ? 1 : 0)
                .background(
                        RoundedCorner(radius: 25, corners: selectedTab == 0 ? [.topLeft, .topRight] : [.bottomRight,.topRight,.topLeft])
                            .fill(selectedTab == 0 ? Color(hex: "fffdf7"): Color(.systemGray6))
                            .frame(width: (UIScreen.main.bounds.width)/2, height: 50)
                            .background(
                                //Border over top/bottom of tab
                                RoundedCorner(radius: 25, corners: selectedTab == 0 ? [.topLeft, .topRight] : [.bottomRight,.topRight,.topLeft])
                                    .fill(Color(.systemGray4))
                                    .frame(width: (UIScreen.main.bounds.width)/2 + 1, height: 50)
                                    .padding(selectedTab == 0 ? .bottom : .top, 3)
                                    .overlay(
                                        //White Rectangle cuts off bottom half of border
                                        Rectangle()
                                            .fill(Color(hex: "fffdf7"))
                                            .padding(selectedTab == 0 ? .top : .bottom, 35)
                                    )
                            )
                    )
                
                Button(action: { selectedTab = 1 }) {
                    VStack(spacing: 8) {
                        Text("Saved")
                            .font(.body)
                            //.fontWeight(selectedTab == 1 ? .semibold : .regular)
                            .foregroundColor(.black)
                        
                    }
                }
                .frame(maxWidth: .infinity)
                .zIndex(selectedTab == 1 ? 2 : 0)
                .background(
                    RoundedCorner(radius: 25, corners: selectedTab == 1 ? [.topLeft, .topRight] : [.bottomRight,.bottomLeft,.topRight,.topLeft])
                        .fill(selectedTab == 1 ? Color(hex: "fffdf7"): Color(.systemGray6))
                        .frame(width: (UIScreen.main.bounds.width)/2 , height: 50)
                        .background(
                            //Border over top of tab
                            RoundedCorner(radius: 25, corners: selectedTab == 1 ? [.topLeft, .topRight] : [.bottomRight,.bottomLeft, .topRight,.topLeft])
                                .fill(Color(.systemGray4))
                                .frame(width: (UIScreen.main.bounds.width)/2 + 1, height: 50)
                                .padding(selectedTab == 1 ? .bottom : .top, 3)
                                .overlay(
                                    //White Rectangle cuts off bottom half of border
                                    Rectangle()
                                        .fill(Color(hex: "fffdf7"))
                                        .padding(selectedTab == 1 ? .top : .bottom, 35)
                                )
                        )
                )
            }
            .padding(.top, 8)
            .padding(.bottom, 10)
            .padding(.horizontal, 0)
            .background(Color(hex: "fffdf7"))

        }
        
        
    }
    
    let foods = ["Apple Pie", "Cheddar Omelet", "Fried Rice", "Butter Chicken", "Steak and Potatoes", "Homemade Yogurt"]
    let foods2 = ["Spaghetti Carbonara", "Sushi Rolls", "Tacos al Pastor", "Fried Chicken","Margherita Pizza", "Ramen"]
    
    // MARK: - Content Grid
    private func contentGrid(recipes: [Recipe]) -> some View {
        let leftColumnItems = recipes.enumerated().compactMap { (idx, recipe) -> (Recipe, Bool)? in
            if idx % 2 == 0 {
                // decide which ones are tall in the left column
                let tall = true  // left column tends to show big hero images in your mock
                return (recipe, tall)
            } else {
                return nil
            }
        }
        
        let rightColumnItems = recipes.enumerated().compactMap { (idx, recipe) -> (Recipe, Bool)? in
            if idx % 2 == 1 {
                // right column tends to be shorter stacked cards in your mock
                let tall = false
                return (recipe, tall)
            } else {
                return nil
            }
        }
        
        return HStack(alignment: .top, spacing: 12) {
            // LEFT COLUMN
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(leftColumnItems.enumerated()), id: \.1.0.id) { id , pair in
                    let (recipe, isTall) = pair
                    
                    NavigationLink(destination: PostView(recipe: recipe).environment(authVM)){
                        RecipeTile(recipe: recipe, tall: id % 2 == 0)
                    }
                }
            }
            
            // RIGHT COLUMN
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(rightColumnItems.enumerated()), id: \.1.0.id) { id, pair in
                    let (recipe, isTall) = pair
                    
                    NavigationLink(destination: PostView(recipe: recipe).environment(authVM)) {
                        RecipeTile(recipe: recipe, tall: id % 2 - 1 == 0)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}


    private func RecipeTile(recipe: Recipe, tall: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            if let firstImage = recipe.media.first,
               let url = URL(string: firstImage) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 160, height: tall ? 220 : 150)  // 🔥 height variant
                .clipped()
                .cornerRadius(10)
            } else {
                Color.gray.opacity(0.3)
                    .frame(height: tall ? 220 : 150)
                    .cornerRadius(10)
            }

            Text(recipe.name)
                .font(.body)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.medium)
                .lineLimit(2)
        }
    }

// MARK: - Custom Shapes
fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockOwnUser = User(
            userId: "yWKqjhEGoeRmBagAr9WyrXFaRBc2",
            username: "kushi",
            email: "kushi@example.com",
            bio: "Lover of food, code, and community!"
        )
        
        let mockOtherUser = User(
            userId: "yWKqjhEGoeRmBagAr9WyrXFaRBc2",
            username: "foodie123",
            email: "foodie@example.com",
            bio: "Always experimenting with flavors 🍜"
        )
        
        Group {
            /*
            NavigationView {
                ProfileView(user: mockOwnUser, isOwnProfile: true)
            }
            .previewDisplayName("Own Profile")
            */
            NavigationView {
                ProfileView(user: mockOtherUser, isOwnProfile: true)
                    .environment(AuthenticationVM())
            }
            .previewDisplayName("Other User Profile")
        }
    }
}
