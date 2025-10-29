//
//  ChallengesView.swift
//  Yes Chef
//
//  Created on 10/29/25.
//

import SwiftUI
import FirebaseFirestore

struct ChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    @State private var selectedTab = 0 // 0 = Challenge Feed, 1 = Leaderboard
    @State private var weekRange = "week 10/19-10/25"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with week and buttons
                HStack {
                    Text(weekRange)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Add Submission Button
                    NavigationLink(destination: AddRecipeMain()) {
                        Image(systemName: "plus.square")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    // Rules/Info Button
                    Button(action: {
                        // Show rules or info
                    }) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                
                // Custom Tab Picker
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            selectedTab = 0
                        }
                    }) {
                        Text("Challenge Feed")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == 0 ? .black : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 0 ? Color(.systemBackground) : Color.clear)
                            .cornerRadius(20)
                    }
                    
                    Button(action: {
                        withAnimation {
                            selectedTab = 1
                        }
                    }) {
                        Text("Leaderboard")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == 1 ? .black : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 1 ? Color(.systemBackground) : Color.clear)
                            .cornerRadius(20)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // This Week Challenge Banner
                VStack(spacing: 8) {
                    Text("This Week")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(viewModel.weeklyPrompt)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(hex: "#FFF9E6"))
                .cornerRadius(12)
                .padding()
                
                // Content based on selected tab
                if selectedTab == 0 {
                    challengeFeedView
                } else {
                    LeaderboardView()
                }
            }
            .background(Color(.systemBackground))
            .onAppear {
                viewModel.fetchWeeklyChallenge()
                viewModel.fetchSubmissions()
            }
        }
    }
    
    var challengeFeedView: some View {
        ScrollView {
            if viewModel.submissions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No submissions yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Be the first to submit a recipe!")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(viewModel.submissions) { submission in
                        SubmissionCard(submission: submission)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Submission Card
struct SubmissionCard: View {
    let submission: ChallengeSubmission
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Recipe Image
            if let imageURL = submission.imageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(12)
                    } else if phase.error != nil {
                        placeholderImage
                    } else {
                        ProgressView()
                            .frame(height: 180)
                    }
                }
            } else {
                placeholderImage
            }
            
            // Food Title
            Text(submission.recipeName)
                .font(.caption)
                .foregroundColor(.black)
                .lineLimit(2)
                .padding(.horizontal, 4)
        }
    }
    
    var placeholderImage: some View {
        Rectangle()
            .fill(LinearGradient(
                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(height: 180)
            .cornerRadius(12)
            .overlay(
                Image(systemName: "photo.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray.opacity(0.5))
            )
    }
}

// MARK: - Challenge Submission Model
struct ChallengeSubmission: Identifiable, Codable {
    var id: String
    let recipeName: String
    let username: String
    let userId: String
    let imageURL: String?
    let likes: Int
    let datePosted: Date
    let challengeWeek: String
    let recipeId: String
}

// MARK: - Challenges ViewModel
class ChallengesViewModel: ObservableObject {
    @Published var weeklyPrompt: String = ""
    @Published var currentWeekId: String = ""
    @Published var submissions: [ChallengeSubmission] = []
    private var db = Firestore.firestore()
    
    func fetchWeeklyChallenge() {
        // Fetch the current week's challenge
        db.collection("current_challenge_submissions")
            .order(by: "week", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching challenge: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    if let doc = snapshot?.documents.first,
                       let prompt = doc.data()["prompt"] as? String {
                        self.weeklyPrompt = prompt
                        self.currentWeekId = doc.documentID
                    } else {
                        // If no challenge exists, use a default
                        self.weeklyPrompt = "a comforting chicken dish"
                        self.currentWeekId = self.getCurrentWeekString()
                    }
                }
            }
    }
    
    func fetchSubmissions() {
        // Listen for the list of challenge submissions which contain only references
        // to recipe posts (e.g., POST_ID / recipeId) plus prompt/week. Then fetch
        // the full recipe documents from the RECIPES collection.
        db.collection("current_challenge_submissions")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching submission references: \(error)")
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No documents in current_challenge_submissions.")
                    DispatchQueue.main.async { self.submissions = [] }
                    return
                }

                // Build a mapping from postId -> week string (for display)
                var postIdToWeek: [String: String] = [:]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"

                print("Found \(documents.count) submission reference docs.")
                for doc in documents {
                    let data = doc.data()
                    // Support multiple possible field names for the post id
                    let explicitId = (data["postId"] as? String)
                        ?? (data["POST_ID"] as? String)
                        ?? (data["recipeId"] as? String)
                    let resolvedId = explicitId ?? doc.documentID // fallback: doc id is the post id

                    // Convert week to string regardless of storage type
                    var weekString: String = ""
                    if let w = data["week"] as? String {
                        weekString = w
                    } else if let ts = data["week"] as? Timestamp {
                        weekString = dateFormatter.string(from: ts.dateValue())
                    }

                    if !resolvedId.isEmpty {
                        postIdToWeek[resolvedId] = weekString
                        print("Submission ref -> postId: \(resolvedId), week: \(weekString)")
                    } else {
                        print("Warning: Missing postId/POST_ID/recipeId in doc id: \(doc.documentID)")
                    }
                }

                let allPostIds = Array(postIdToWeek.keys)
                if allPostIds.isEmpty {
                    print("No post IDs extracted; feed will be empty.")
                    DispatchQueue.main.async { self.submissions = [] }
                    return
                }

                // Firestore supports 'in' queries with up to 10 items. Chunk if needed.
                let chunkSize = 10
                var chunks: [[String]] = []
                var index = 0
                while index < allPostIds.count {
                    let end = min(index + chunkSize, allPostIds.count)
                    chunks.append(Array(allPostIds[index..<end]))
                    index = end
                }

                var fetchedSubmissions: [ChallengeSubmission] = []
                let group = DispatchGroup()

                for chunk in chunks {
                    group.enter()
                    print("Querying RECIPES for \(chunk.count) ids: \(chunk)")
                    self.db.collection("RECIPES")
                        .whereField(FieldPath.documentID(), in: chunk)
                        .getDocuments { recipeSnapshot, err in
                            defer { group.leave() }
                            if let err = err {
                                print("Error fetching recipes: \(err)")
                                return
                            }

                            guard let recipeDocs = recipeSnapshot?.documents else { return }
                            print("Fetched \(recipeDocs.count) recipe docs for chunk.")

                            for recipeDoc in recipeDocs {
                                let r = recipeDoc.data()

                                let recipeName = (r["recipeName"] as? String)
                                    ?? (r["name"] as? String)
                                    ?? "Untitled Recipe"

                                let username = (r["username"] as? String)
                                    ?? (r["authorName"] as? String)
                                    ?? ""

                                let userId = (r["userId"] as? String)
                                    ?? (r["authorId"] as? String)
                                    ?? ""

                                let imageURL = (r["imageURL"] as? String)
                                    ?? (r["coverUrl"] as? String)
                                    ?? (r["image"] as? String)

                                let likes = r["likes"] as? Int ?? 0

                                let datePosted: Date = {
                                    if let ts = r["datePosted"] as? Timestamp { return ts.dateValue() }
                                    if let created = recipeDoc["_createTime"] as? Timestamp { return created.dateValue() }
                                    return Date()
                                }()

                                let week = postIdToWeek[recipeDoc.documentID] ?? ""

                                fetchedSubmissions.append(
                                    ChallengeSubmission(
                                        id: recipeDoc.documentID,
                                        recipeName: recipeName,
                                        username: username,
                                        userId: userId,
                                        imageURL: imageURL,
                                        likes: likes,
                                        datePosted: datePosted,
                                        challengeWeek: week,
                                        recipeId: recipeDoc.documentID
                                    )
                                )
                            }
                        }
                }

                group.notify(queue: .main) {
                    // Sort by date desc for a consistent feed
                    print("Total mapped submissions: \(fetchedSubmissions.count)")
                    self.submissions = fetchedSubmissions.sorted(by: { $0.datePosted > $1.datePosted })
                }
            }
    }
    
    private func getCurrentWeekString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}



#Preview {
    ChallengesView()
        .environment(AuthenticationVM())
}
