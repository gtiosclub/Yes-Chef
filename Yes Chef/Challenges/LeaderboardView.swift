import SwiftUI
import Foundation
import Firebase

struct LeaderboardView: View {
    @StateObject private var data: LeaderboardData = LeaderboardData()
    @State private var reloadTrigger: Bool = false
    @State private var weeklyPrompt: String = "Loading prompt..."
    @State private var showHistory: Bool = false
    @State private var selectedTab = 0
    @State private var searchText: String = ""
    @Environment(AuthenticationVM.self) var authVM: AuthenticationVM


    var body: some View {
            VStack(spacing: 0) {
                // Fixed header with title and history button
                HStack {
                    Text("Weekly Challenge")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    NavigationLink(destination: HistoryTab().environment(authVM)) {
                        Image(systemName: "clock.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5)

                // Tab Selection
                tabSelection

                // Content based on selected tab
                if selectedTab == 0 {
                    challengeFeedView
                } else {
                    leaderboardView
                }
            } // Close outer VStack
        .task {
            data.fetchUserRecipes()
            await fetchWeeklyPrompt()
        }
    } // Close body

    // MARK: - Tab Selection
    private var tabSelection: some View {
        ZStack(alignment: .bottomLeading){

            RoundedRectangle(cornerRadius: 16)
                .fill(Color(Color.white))
                        .frame(height: 56)


            HStack(spacing: 0) {

                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 8) {
                        Text("Challenge Feed")
                            .font(.body)
                            .fontWeight(selectedTab == 0 ? .semibold : .regular)
                            .foregroundColor(.black)

                    }
                }
                .padding(.bottom , 10)
                .frame(maxWidth: .infinity)
                .zIndex(selectedTab == 0 ? 1 : 0)
                .background(
                        RoundedCorner(radius: 25, corners: selectedTab == 0 ? [.topLeft, .topRight] : [.bottomRight,.topRight,.topLeft])
                            .fill(selectedTab == 0 ? Color.white: Color(.systemGray6))
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
                                            .fill(Color.white)
                                            .padding(selectedTab == 0 ? .top : .bottom, 35)
                                    )
                            )
                    )

                Button(action: { selectedTab = 1 }) {
                    VStack(spacing: 8) {
                        Text("Leaderboard")
                            .font(.body)
                            .fontWeight(selectedTab == 1 ? .semibold : .regular)
                            .foregroundColor(.black)

                    }
                }
                .frame(maxWidth: .infinity)
                .zIndex(selectedTab == 1 ? 2 : 0)
                .background(
                    RoundedCorner(radius: 25, corners: selectedTab == 1 ? [.topLeft, .topRight] : [.bottomRight,.bottomLeft,.topRight,.topLeft])
                        .fill(selectedTab == 1 ? Color.white: Color(.systemGray6))
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
                                        .fill(Color.white)
                                        .padding(selectedTab == 1 ? .top : .bottom, 35)
                                )
                        )
                )
            }
            .padding(.top, 8)
            .padding(.bottom, 10)
            .padding(.horizontal, 0)

        }


    }

    // MARK: - Challenge Feed View
    private var challengeFeedView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weekly prompt
                VStack(spacing: 8) {
                    Text("This Week's Challenge")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(weeklyPrompt)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)

                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .padding(.horizontal)

                // Add Submission Button
                NavigationLink(
                    destination: AddRecipeMain(submitToWeeklyChallenge: true)
                        .environment(authVM)
                    
                ) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Add Submission")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.83))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search recipes...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                // Grid view of all submissions
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]

                let filteredEntries = searchText.isEmpty ? data.currentLeaderboard.entries : data.currentLeaderboard.entries.filter { entry in
                    entry.recipeName.localizedCaseInsensitiveContains(searchText) ||
                    entry.user.username.localizedCaseInsensitiveContains(searchText)
                }

                if filteredEntries.isEmpty {
                    Text("No submissions yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(filteredEntries) { entry in
                            NavigationLink(destination: RecipeDetailView(recipeId: entry.id).environment(authVM)) {
                                ChallengeRecipeCard(entry: entry)
                                    .environment(authVM)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Leaderboard View
    private var leaderboardView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weekly prompt
                VStack(spacing: 8) {
                    Text("This Week's Challenge")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(weeklyPrompt)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .padding(.horizontal)

                // Podium for top 3
                HStack {
                    Spacer()

                    HStack(alignment: .bottom, spacing: 40) {
                        VStack {
                            Text("2nd")
                                .font(.caption)
                            AsyncImage(url: URL(string: data.currentLeaderboard.entries.count >= 2 ? data.currentLeaderboard.entries[1].user.profileImageURL ?? "" : "")) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.blue)
                                }
                            }
                            Text(data.currentLeaderboard.entries.count >= 2 ? data.currentLeaderboard.entries[1].user.username : "Chef #2")
                                .font(.caption2)
                            Text(data.currentLeaderboard.entries.count >= 2 ? data.currentLeaderboard.entries[1].recipeName : "Recipe")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .offset(y: 20)

                        VStack {
                            ZStack(alignment: .top) {
                                AsyncImage(url: URL(string: data.currentLeaderboard.entries.count >= 1 ? data.currentLeaderboard.entries[0].user.profileImageURL ?? "" : "")) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.blue)
                                    }
                                }
                                Image("ChefHat")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .offset(y: -25)
                                    .foregroundColor(.gray)
                            }
                            Text(data.currentLeaderboard.entries.count >= 1 ? data.currentLeaderboard.entries[0].user.username : "Chef #1")
                                .font(.caption2)
                            Text(data.currentLeaderboard.entries.count >= 1 ? data.currentLeaderboard.entries[0].recipeName : "Recipe")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .offset(y: -10)

                        VStack {
                            Text("3rd")
                                .font(.caption)
                            AsyncImage(url: URL(string: data.currentLeaderboard.entries.count >= 3 ? data.currentLeaderboard.entries[2].user.profileImageURL ?? "" : "")) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.blue)
                                }
                            }
                            Text(data.currentLeaderboard.entries.count >= 3 ? data.currentLeaderboard.entries[2].user.username : "Chef #3")
                                .font(.caption2)
                            Text(data.currentLeaderboard.entries.count >= 3 ? data.currentLeaderboard.entries[2].recipeName : "Recipe")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .offset(y: 20)
                    }

                    Spacer()
                }
                .padding(.top)

                // Top 5 Leaderboard (excluding top 3 shown in podium)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(data.currentLeaderboard.entries.dropFirst(3).prefix(2)) { entry in
                            LeaderboardRow(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 100)
            }
            .padding(.bottom, 20)
        }
    }

    // Fetch the current weekly challenge prompt
    private func fetchWeeklyPrompt() async {
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("weeklyChallenge").document("current").getDocument()
            if document.exists, let data = document.data(), let prompt = data["prompt"] as? String {
                await MainActor.run {
                    self.weeklyPrompt = prompt
                }
            } else {
                // Document doesn't exist, initialize it
                print("⚠️ Weekly challenge not initialized. Initializing now...")
                await initializeWeeklyChallenge()
            }
        } catch {
            print("Error fetching weekly prompt: \(error.localizedDescription)")
            await MainActor.run {
                self.weeklyPrompt = "Could not load challenge prompt"
            }
        }
    }

    // Initialize weekly challenge if it doesn't exist
    private func initializeWeeklyChallenge() async {
        await MainActor.run {
            self.weeklyPrompt = "Initializing challenge..."
        }

        await WeeklyChallengeManager.initializeWeeklyChallenge()

        // Try fetching again after initialization
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("weeklyChallenge").document("current").getDocument()
            if let data = document.data(), let prompt = data["prompt"] as? String {
                await MainActor.run {
                    self.weeklyPrompt = prompt
                }
            } else {
                await MainActor.run {
                    self.weeklyPrompt = "Create your best dish this week!"
                }
            }
        } catch {
            await MainActor.run {
                self.weeklyPrompt = "Create your best dish this week!"
            }
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardData.LeaderboardEntry

    var body: some View {
        HStack {
            Text("\(entry.rank)")
                .font(.headline)
                .frame(width: 30)
            
            AsyncImage(url: URL(string: entry.user.profileImageURL ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.user.username)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text(entry.recipeName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(entry.likes)")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(radius: 2)
        )
    }
}

struct ChallengeRecipeCard: View {
    let entry: LeaderboardData.LeaderboardEntry
    @Environment(AuthenticationVM.self) var authVM

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Recipe image placeholder or first media
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(height: 120)
                .overlay(
                    VStack {
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                )

            VStack(alignment: .leading, spacing: 4) {
                // Username on top with profile image
                HStack {
                    AsyncImage(url: URL(string: entry.user.profileImageURL ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                        }
                    }
                    Text(entry.user.username)
                        .font(.headline)
                        .lineLimit(1)
                }

                // Recipe name under username
                Text(entry.recipeName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Likes at bottom
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("\(entry.likes)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Helper view to fetch recipe and navigate to PostView
struct RecipeDetailView: View {
    let recipeId: String
    @State private var recipe: Recipe? = nil
    @State private var isLoading: Bool = true
    @Environment(AuthenticationVM.self) var authVM

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                    Text("Loading recipe...")
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            } else if let recipe = recipe {
                PostView(recipe: recipe)
                    .environment(authVM)
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Recipe not found")
                        .font(.headline)
                        .padding()
                }
            }
        }
        .task {
            recipe = await Recipe.fetchById(recipeId)
            isLoading = false
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LeaderboardView()
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
