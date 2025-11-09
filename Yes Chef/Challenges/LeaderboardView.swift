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
        VStack(spacing: 16) {
            // MARK: - Header
            HStack {
                Text("Weekly Challenge")
                    .font(.largeTitle.bold())
                Spacer()
                NavigationLink(destination: HistoryTab()) {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 10)
            .background(Color(UIColor.systemGray6))

            // MARK: - Tabs
            tabSelection

            // MARK: - Content
            if selectedTab == 0 {
                challengeFeedView
            } else {
                leaderboardView
            }
        }
        .background(Color(UIColor.systemGray6))
        .task {
            data.fetchUserRecipes()
            await fetchWeeklyPrompt()
        }
    }

    // MARK: - Tab Selection
    // MARK: - Tab Selection
    private var tabSelection: some View {
        ZStack(alignment: .bottomLeading) {
            // Background rounded rectangle bar (like in ProfileView)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#fffffc"))
                .frame(height: 56)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

            HStack(spacing: 0) {
                // Challenge Feed Tab
                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 8) {
                        Text("Challenge Feed")
                            .font(.body)
                            .fontWeight(selectedTab == 0 ? .semibold : .regular)
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .zIndex(selectedTab == 0 ? 1 : 0)
                .background(
                    RoundedCorner(radius: 25,
                                  corners: selectedTab == 0 ? [.topLeft, .topRight]
                                                            : [.bottomRight, .topRight, .topLeft])
                        .fill(selectedTab == 0 ? Color.white : Color(.systemGray6))
                        .frame(width: UIScreen.main.bounds.width / 2, height: 50)
                        .background(
                            RoundedCorner(radius: 25,
                                          corners: selectedTab == 0 ? [.topLeft, .topRight]
                                                                    : [.bottomRight, .topRight, .topLeft])
                                .fill(Color(.systemGray4))
                                .frame(width: UIScreen.main.bounds.width / 2 + 1, height: 50)
                                .padding(selectedTab == 0 ? .bottom : .top, 3)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.white)
                                        .padding(selectedTab == 0 ? .top : .bottom, 35)
                                )
                        )
                )

                // Leaderboard Tab
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
                    RoundedCorner(radius: 25,
                                  corners: selectedTab == 1 ? [.topLeft, .topRight]
                                                            : [.bottomRight, .bottomLeft, .topRight, .topLeft])
                        .fill(selectedTab == 1 ? Color.white : Color(.systemGray6))
                        .frame(width: UIScreen.main.bounds.width / 2, height: 50)
                        .background(
                            RoundedCorner(radius: 25,
                                          corners: selectedTab == 1 ? [.topLeft, .topRight]
                                                                    : [.bottomRight, .bottomLeft, .topRight, .topLeft])
                                .fill(Color(.systemGray4))
                                .frame(width: UIScreen.main.bounds.width / 2 + 1, height: 50)
                                .padding(selectedTab == 1 ? .bottom : .top, 3)
                                .overlay(
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
        .padding(.horizontal)
        .padding(.top, 10) // spacing below the header
        .padding(.bottom, 10) // spacing before the content starts
        .padding(.vertical, 8)
    }


    // MARK: - Challenge Feed View
    private var challengeFeedView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weekly prompt card
                VStack(spacing: 8) {
                    Text("This Week's Challenge")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(weeklyPrompt)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "fffffc"))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal)

                // Add Submission button
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
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search recipes...", text: $searchText)
                        .font(.body)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal)

                // Grid view of submissions
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                let filteredEntries = searchText.isEmpty ? data.currentLeaderboard.entries : data.currentLeaderboard.entries.filter { entry in
                    entry.recipeName.localizedCaseInsensitiveContains(searchText) ||
                    entry.user.username.localizedCaseInsensitiveContains(searchText)
                }

                if filteredEntries.isEmpty {
                    Text("No submissions yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(filteredEntries) { entry in
                            NavigationLink(destination: RecipeDetailView(recipeId: entry.id)) {
                                ChallengeRecipeCard(entry: entry)
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
                // Weekly prompt card
                VStack(spacing: 8) {
                    Text("This Week's Challenge")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(weeklyPrompt)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal)

                // Podium section
                HStack {
                    Spacer()
                    HStack(alignment: .bottom, spacing: 40) {
                        podiumView(rank: 2)
                            .offset(y: 20)
                        podiumView(rank: 1)
                            .offset(y: -10)
                        podiumView(rank: 3)
                            .offset(y: 20)
                    }
                    Spacer()
                }
                .padding(.top)

                // Horizontal scroll for top 5 (after podium)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) { // no spacing between cards
                        ForEach(data.currentLeaderboard.entries.dropFirst(3).prefix(5)) { entry in
                            LeaderboardRow(entry: entry)
                                .frame(width: UIScreen.main.bounds.width)
                        }
                    }
                }
                .frame(height: 120)
                .padding(.horizontal, 0)
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Podium Helper
    private func podiumView(rank: Int) -> some View {
        VStack {
            if rank != 1 {
                Text("\(rank)ᵗʰ")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            AsyncImage(url: URL(string: data.currentLeaderboard.entries.count >= rank ? data.currentLeaderboard.entries[rank - 1].user.profileImageURL ?? "" : "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: rank == 1 ? 100 : 60, height: rank == 1 ? 100 : 60)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: rank == 1 ? 100 : 60, height: rank == 1 ? 100 : 60)
                        .foregroundColor(.orange.opacity(0.7))
                }
            }
            if rank == 1 {
                Image("ChefHat")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .offset(y: -110)
            }
            Text(data.currentLeaderboard.entries.count >= rank ? data.currentLeaderboard.entries[rank - 1].user.username : "Chef #\(rank)")
                .font(.caption)
            Text(data.currentLeaderboard.entries.count >= rank ? data.currentLeaderboard.entries[rank - 1].recipeName : "Recipe")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Weekly Prompt Fetching
    private func fetchWeeklyPrompt() async {
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("weeklyChallenge").document("current").getDocument()
            if document.exists, let data = document.data(), let prompt = data["prompt"] as? String {
                await MainActor.run { self.weeklyPrompt = prompt }
            } else {
                print("⚠️ Weekly challenge not initialized. Initializing now...")
                await initializeWeeklyChallenge()
            }
        } catch {
            print("Error fetching weekly prompt: \(error.localizedDescription)")
            await MainActor.run { self.weeklyPrompt = "Could not load challenge prompt" }
        }
    }

    private func initializeWeeklyChallenge() async {
        await MainActor.run { self.weeklyPrompt = "Initializing challenge..." }
        await WeeklyChallengeManager.initializeWeeklyChallenge()
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("weeklyChallenge").document("current").getDocument()
            if let data = document.data(), let prompt = data["prompt"] as? String {
                await MainActor.run { self.weeklyPrompt = prompt }
            } else {
                await MainActor.run { self.weeklyPrompt = "Create your best dish this week!" }
            }
        } catch {
            await MainActor.run { self.weeklyPrompt = "Create your best dish this week!" }
        }
    }
}

// MARK: - Row + Card Views
struct LeaderboardRow: View {
    let entry: LeaderboardData.LeaderboardEntry

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(entry.rank)")
                .font(.headline)
                .foregroundColor(.orange)
                .frame(width: 30)
            AsyncImage(url: URL(string: entry.user.profileImageURL ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFit().frame(width: 50, height: 50).clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable().scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.orange.opacity(0.6))
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.user.username)
                    .font(.headline)
                Text(entry.recipeName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "heart.fill").foregroundColor(.red)
                Text("\(entry.likes)").font(.subheadline)
            }
        }
        .padding()
        .background(Color(hex: "fffffc"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

struct ChallengeRecipeCard: View {
    let entry: LeaderboardData.LeaderboardEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.15))
                .frame(height: 120)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundColor(.orange.opacity(0.6))
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    AsyncImage(url: URL(string: entry.user.profileImageURL ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit().frame(width: 20, height: 20).clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.orange.opacity(0.6))
                        }
                    }
                    Text(entry.user.username)
                        .font(.headline)
                        .lineLimit(1)
                }
                Text(entry.recipeName)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
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
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

#Preview {
    LeaderboardView()
}



// Helper view to fetch recipe and navigate to PostView
struct RecipeDetailView: View {
    let recipeId: String
    @State private var recipe: Recipe? = nil
    @State private var isLoading: Bool = true

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
