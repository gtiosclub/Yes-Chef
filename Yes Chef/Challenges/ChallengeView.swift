//
//  ChallengesView.swift
//  Yes Chef
//
//  Created on 10/29/25
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
// id == recipeID (doc ID in both collections). No separate recipeId field.
struct ChallengeSubmission: Identifiable, Codable {
    var id: String                // recipeID / documentID
    let recipeName: String
    let username: String
    let userId: String
    let imageURL: String?
    let likes: Int
    let datePosted: Date
    let challengeWeek: String
}

// MARK: - Challenges ViewModel
class ChallengesViewModel: ObservableObject {
    @Published var weeklyPrompt: String = ""
    @Published var currentWeekId: String = ""
    @Published var submissions: [ChallengeSubmission] = []
    private var db = Firestore.firestore()
    
    // Reads latest prompt from any submission doc (they all carry prompt/week)
    func fetchWeeklyChallenge() {
        db.collection("current_challenge_submissions")
            .order(by: "week", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching challenge: \(error)")
                    DispatchQueue.main.async {
                        self.weeklyPrompt = "a comforting chicken dish"
                        self.currentWeekId = self.getCurrentWeekString()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    if let doc = snapshot?.documents.first {
                        self.weeklyPrompt = (doc.data()["prompt"] as? String) ?? "a comforting chicken dish"
                        // Keep a readable week label if you want to show it
                        if let w = doc.data()["week"] as? String {
                            self.currentWeekId = w
                        } else if let ts = doc.data()["week"] as? Timestamp {
                            self.currentWeekId = Self.formatYMD(ts.dateValue())
                        } else {
                            self.currentWeekId = self.getCurrentWeekString()
                        }
                    } else {
                        self.weeklyPrompt = "a comforting chicken dish"
                        self.currentWeekId = self.getCurrentWeekString()
                    }
                }
            }
    }
    
    func fetchSubmissions() {
        // Listen to submission refs: each doc ID === recipeID; fields: prompt, week
        db.collection("current_challenge_submissions")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching submission references: \(error)")
                    DispatchQueue.main.async { self.submissions = [] }
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    DispatchQueue.main.async { self.submissions = [] }
                    return
                }
                
                // Build recipeID -> week map (doc ID is the recipeID)
                var weekById: [String: String] = [:]
                for doc in documents {
                    let recipeId = doc.documentID
                    let data = doc.data()
                    let weekString: String = {
                        if let s = data["week"] as? String { return s }
                        if let ts = data["week"] as? Timestamp { return Self.formatYMD(ts.dateValue()) }
                        return ""
                    }()
                    weekById[recipeId] = weekString
                }
                
                let allRecipeIds = Array(weekById.keys)
                if allRecipeIds.isEmpty {
                    DispatchQueue.main.async { self.submissions = [] }
                    return
                }
                
                // Chunk recipe IDs into batches of 10 for Firestore "in" query
                let chunkSize = 10
                var chunks: [[String]] = []
                var index = 0
                while index < allRecipeIds.count {
                    let end = min(index + chunkSize, allRecipeIds.count)
                    chunks.append(Array(allRecipeIds[index..<end]))
                    index = end
                }
                
                var fetched: [ChallengeSubmission] = []
                let group = DispatchGroup()
                
                for chunk in chunks {
                    group.enter()
                    self.db.collection("RECIPES")
                        .whereField(FieldPath.documentID(), in: chunk)
                        .getDocuments { recipeSnapshot, err in
                            defer { group.leave() }
                            if let err = err {
                                print("Error fetching recipes: \(err)")
                                return
                            }
                            
                            guard let recipeDocs = recipeSnapshot?.documents else { return }
                            
                            for recipeDoc in recipeDocs {
                                let r = recipeDoc.data()
                                let recipeId = recipeDoc.documentID  // source of truth
                                
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
                                    ?? ((r["media"] as? [String])?.first)
                                
                                let likes = r["likes"] as? Int ?? 0
                                
                                let datePosted: Date = {
                                    if let ts = r["datePosted"] as? Timestamp { return ts.dateValue() }
                                    return Date(timeIntervalSince1970: 0)
                                }()
                                
                                let week = weekById[recipeId] ?? ""
                                
                                fetched.append(
                                    ChallengeSubmission(
                                        id: recipeId,
                                        recipeName: recipeName,
                                        username: username,
                                        userId: userId,
                                        imageURL: imageURL,
                                        likes: likes,
                                        datePosted: datePosted,
                                        challengeWeek: week
                                    )
                                )
                            }
                        }
                }
                
                group.notify(queue: .main) {
                    self.submissions = fetched.sorted(by: { $0.datePosted > $1.datePosted })
                }
            }
    }
    
    private func getCurrentWeekString() -> String {
        Self.formatYMD(Date())
    }
    
    private static func formatYMD(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

#Preview {
    ChallengesView()
        .environment(AuthenticationVM())
}
