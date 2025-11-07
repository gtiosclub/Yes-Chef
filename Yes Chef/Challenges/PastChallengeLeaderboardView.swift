//
//  PastChallengeLeaderboardView.swift
//  Yes Chef
//
//  View for displaying past weekly challenge leaderboards from history
//

import SwiftUI
import FirebaseFirestore
import Firebase

struct PastChallengeLeaderboardView: View {
    let historyBlock: HistoryBlock

    @StateObject private var data = PastChallengeData()

    var body: some View {
        VStack(spacing: 20) {

            Text("Past Challenge")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 4) {
                Text(historyBlock.date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(historyBlock.challengeName)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
            .padding(.horizontal)

            HStack {
                Spacer()

                HStack(alignment: .bottom, spacing: 40) {
                    // 2nd place
                    VStack {
                        Text("2nd")
                            .font(.caption)
                        AsyncImage(url: URL(string: data.entries.count >= 2 ? data.entries[1].user.profileImageURL ?? "" : "")) { phase in
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
                        Text(data.entries.count >= 2 ? data.entries[1].user.username : "Chef #2")
                            .font(.caption2)
                        Text(data.entries.count >= 2 ? data.entries[1].recipeName : "Recipe")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .offset(y: 20)

                    // 1st place
                    VStack {
                        ZStack(alignment: .top) {
                            AsyncImage(url: URL(string: data.entries.count >= 1 ? data.entries[0].user.profileImageURL ?? "" : "")) { phase in
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
                        Text(data.entries.count >= 1 ? data.entries[0].user.username : "Chef #1")
                            .font(.caption2)
                        Text(data.entries.count >= 1 ? data.entries[0].recipeName : "Recipe")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .offset(y: -10)

                    // 3rd place
                    VStack {
                        Text("3rd")
                            .font(.caption)
                        AsyncImage(url: URL(string: data.entries.count >= 3 ? data.entries[2].user.profileImageURL ?? "" : "")) { phase in
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
                        Text(data.entries.count >= 3 ? data.entries[2].user.username : "Chef #3")
                            .font(.caption2)
                        Text(data.entries.count >= 3 ? data.entries[2].recipeName : "Recipe")
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
                    ForEach(data.entries.dropFirst(3).prefix(2)) { entry in
                        LeaderboardRow(entry: entry)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)

            Text("All Submissions")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            // Grid view of all submissions
            ScrollView {
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(data.entries) { entry in
                        ChallengeRecipeCard(entry: entry)
                    }
                }
                .padding(.horizontal)
            }
        }
        .task {
            await data.fetchPastChallengeRecipes(recipeIDs: historyBlock.submissions)
        }
        .navigationTitle("Challenge History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

@MainActor
class PastChallengeData: ObservableObject {
    @Published var entries: [LeaderboardData.LeaderboardEntry] = []

    private var db = Firestore.firestore()

    func fetchPastChallengeRecipes(recipeIDs: [String]) async {
        guard !recipeIDs.isEmpty else {
            self.entries = []
            return
        }

        // Firebase has a limit of 10 items for 'in' queries, so we need to batch if more than 10
        let batches = recipeIDs.chunked(into: 10)
        var allEntries: [LeaderboardData.LeaderboardEntry] = []

        for batch in batches {
            do {
                let snapshot = try await db.collection("RECIPES")
                    .whereField(FieldPath.documentID(), in: batch)
                    .getDocuments()

                // Fetch user data for all recipes in this batch
                await withTaskGroup(of: LeaderboardData.LeaderboardEntry?.self) { group in
                    for doc in snapshot.documents {
                        let data = doc.data()
                        let idString = doc.documentID

                        group.addTask {
                            guard let userId = data["userId"] as? String,
                                  let recipeName = data["name"] as? String,
                                  let likes = data["likes"] as? Int else {
                                return nil
                            }

                            // Fetch username from users collection
                            var username = userId // Fallback to userId
                            var profileImageURL: String? = nil

                            do {
                                let userDoc = try await self.db.collection("users").document(userId).getDocument()
                                if let userData = userDoc.data() {
                                    username = userData["username"] as? String ?? userId
                                    profileImageURL = userData["profileImageURL"] as? String
                                }
                            } catch {
                                print("⚠️ Error fetching user \(userId): \(error.localizedDescription)")
                            }

                            let user = LeaderboardData.UserTest(
                                id: userId,
                                username: username,
                                profileImageURL: profileImageURL
                            )

                            return LeaderboardData.LeaderboardEntry(
                                id: idString,
                                rank: 0,
                                user: user,
                                recipeName: recipeName,
                                likes: likes
                            )
                        }
                    }

                    for await entry in group {
                        if let entry = entry {
                            allEntries.append(entry)
                        }
                    }
                }
            } catch {
                print("Error fetching past challenge recipes: \(error.localizedDescription)")
            }
        }

        // Sort by likes descending and assign ranks
        allEntries.sort { $0.likes > $1.likes }

        for i in allEntries.indices {
            allEntries[i] = LeaderboardData.LeaderboardEntry(
                id: allEntries[i].id,
                rank: i + 1,
                user: allEntries[i].user,
                recipeName: allEntries[i].recipeName,
                likes: allEntries[i].likes
            )
        }

        self.entries = allEntries
    }
}

// Extension to chunk arrays for batching
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    PastChallengeLeaderboardView(
        historyBlock: HistoryBlock(
            date: "Jan 1, 2025",
            challengeName: "Best comfort food dish",
            submissions: []
        )
    )
}
