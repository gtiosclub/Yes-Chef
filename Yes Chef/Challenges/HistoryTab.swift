import SwiftUI
import UIKit
import FirebaseFirestore

struct HistoryTab: View {
    @State private var showPopup = false
    @StateObject private var viewModel = HistoryViewModel()
    @State private var challengeManager = WeeklyChallengeManager()
    @State private var searchEntry: String = ""
    @State private var thisWeekPrompt: String = "Loading..."
    @State private var selectedYear: String = ""
    @State private var isExpanded: Bool = false
    @State private var showResetConfirmation: Bool = false
    @State private var searchText = ""
    @State private var searchDate: String? = nil
    
    var allYears: [String] {
        Array(Set(viewModel.history.compactMap { $0.date.prefix(4).description })).sorted()
    }

    var selectedItems: [HistoryBlock] {
        viewModel.history.filter { historyItem in
            let matchedSearch = (searchText.isEmpty || historyItem.challengeName.localizedCaseInsensitiveContains(searchText)) ||
            (searchText.isEmpty || historyItem.date.localizedCaseInsensitiveContains(searchText))
            let matchedYear = searchDate == nil || historyItem.date.prefix(4).description == searchDate
            return matchedSearch && matchedYear
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Header
            HStack {
                Text("History")
                    .font(.largeTitle.bold())
                Spacer()
                Button(action: { showResetConfirmation = true }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)

            // MARK: - Current Challenge
            VStack(spacing: 8) {
                Text("October 19th, 2025 - October 25th, 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(thisWeekPrompt)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.orange.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)

            // MARK: - Search + Year Filter
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search Key Words", text: $searchText)
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

                Menu {
                    Button("All Years") { searchDate = nil }
                    ForEach(allYears, id: \.self) { year in
                        Button(year) { searchDate = year }
                    }
                } label: {
                    HStack {
                        Text(searchDate ?? "Select Year")
                            .foregroundColor(searchDate == nil ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
            }

            // MARK: - History List
            ScrollView {
                VStack(spacing: 12) {
                    if viewModel.history.isEmpty {
                        Text("No history yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(selectedItems) { week in
                            NavigationLink {
                                PastChallengeLeaderboardView(historyBlock: week)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(week.date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(week.challengeName)
                                        .font(.body.bold())
                                        .foregroundColor(.black)
                                    Text("\(week.submissions.count) submissions")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .task {
            await fetchWeeklyPrompt()
            viewModel.fetchHistory()
        }
        .alert("Test Weekly Reset", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                Task {
                    await challengeManager.performWeeklyReset()
                    await fetchWeeklyPrompt()
                    viewModel.fetchHistory()
                }
            }
        } message: {
            Text("This will archive current submissions, generate a new prompt, and clear the current challenge. Continue?")
        }
        .overlay(
            Group {
                if challengeManager.isResetting {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Resetting weekly challenge...")
                                .padding()
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
        )

        .background(Color(hex: "#fffdf7"))
    } // Close body


    private func fetchWeeklyPrompt() async {
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("weeklyChallenge").document("current").getDocument()
            if document.exists, let data = document.data(), let prompt = data["prompt"] as? String {
                await MainActor.run { self.thisWeekPrompt = prompt }
            } else {
                await MainActor.run { self.thisWeekPrompt = "No weekly challenge active" }
            }
        } catch {
            print("Error fetching weekly prompt: \(error.localizedDescription)")
            await MainActor.run { self.thisWeekPrompt = "Could not load challenge prompt" }
        }
    }
}

#Preview {
    HistoryTab()
}
