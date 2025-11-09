//
//  HistoryTab.swift
//  Yes Chef
//
//  Created by Nidhi Krishna on 9/20/25.
//

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
            let matchedSearch = (searchText.isEmpty || historyItem.challengeName.localizedCaseInsensitiveContains(searchText)) || (searchText.isEmpty || historyItem.date.localizedCaseInsensitiveContains(searchText))
            let matchedYear = searchDate == nil || historyItem.date.prefix(4).description == searchDate
            return matchedSearch && matchedYear
        }
    }



    var body: some View {
            VStack(spacing: 10) {
                HStack {
                    Text("History")
                        .font(.largeTitle)

                    Spacer()

                    // Test Reset Button
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("Test Reset")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            
            
            VStack(spacing: 8) {
                Text("This week:")
                    .foregroundStyle(Color(.systemGray))
                    .font(.subheadline)
                Text(thisWeekPrompt)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
            }
                .frame(maxWidth: 328)
                .padding()
                .background(Color(.systemGray4))
                .cornerRadius(10)


                //Custom Search
                VStack(spacing: 0) {
                    HStack {
                        TextField("Search Prompt", text: $searchText)
                            .font(.title3)
                            .padding(.vertical, 12)
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.black)
                        
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: 328, maxHeight: 57)
                    .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                    //Dropdown date search
                    Menu {
                        Button("All Years") { searchDate = nil }
                        ForEach(allYears, id: \.self) { year in
                            Button(year) { searchDate = year }
                        }
                    } label: {
                        HStack {
                            Text(searchDate ?? "Search year")
                                .foregroundColor(searchDate == nil ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: 328, maxHeight: 57)
                        .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                        .padding(.vertical)
                    }

                ScrollView {
                    if viewModel.history.isEmpty {
                        Text("No history yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        VStack (spacing: 10){
                            ForEach(selectedItems) { week in
                                NavigationLink {
                                    PastChallengeLeaderboardView(historyBlock: week)
                                } label: {
                                    VStack () {
                                        Text(week.date)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.subheadline)

                                        Text(week.challengeName)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.black)
                                            .font(.title3)

                                        Text("\(week.submissions.count) submissions")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    .padding(.horizontal,10)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: 328)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray4))

                                    )

                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 328, height: 400)
        } // Close main VStack
        .task {
            await fetchWeeklyPrompt()
            viewModel.fetchHistory()
        }
        .alert("Test Weekly Reset", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                Task {
                    await challengeManager.performWeeklyReset()
                    // Refresh data
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

    // Fetch the current weekly challenge prompt
    private func fetchWeeklyPrompt() async {
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("weeklyChallenge").document("current").getDocument()
            if document.exists, let data = document.data(), let prompt = data["prompt"] as? String {
                await MainActor.run {
                    self.thisWeekPrompt = prompt
                }
            } else {
                // Document doesn't exist, show default message
                await MainActor.run {
                    self.thisWeekPrompt = "No weekly challenge active"
                }
            }
        } catch {
            print("Error fetching weekly prompt: \(error.localizedDescription)")
            await MainActor.run {
                self.thisWeekPrompt = "Could not load challenge prompt"
            }
        }
    }
} // Close struct

#Preview {
    HistoryTab()
}
