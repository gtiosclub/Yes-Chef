//
//  WeeklyChallengeManager.swift
//  Yes Chef
//
//  Weekly Challenge Management System
//

import Foundation
import FirebaseFirestore
import Observation

@Observable class WeeklyChallengeManager {
    private let db = Firestore.firestore()
    private let aiViewModel = AIViewModel()

    var isResetting: Bool = false
    var lastResetStatus: String = ""

    /// Performs the weekly reset: archives current submissions, generates new prompt, clears current submissions
    func performWeeklyReset() async {
        await MainActor.run {
            self.isResetting = true
            self.lastResetStatus = "Starting weekly reset..."
        }

        print("🔄 Starting weekly challenge reset...")

        // Step 1: Get current prompt
        guard let currentPrompt = await getCurrentPrompt() else {
            await MainActor.run {
                self.lastResetStatus = "❌ Failed to get current prompt"
                self.isResetting = false
            }
            return
        }

        print("📝 Current prompt: \(currentPrompt)")

        // Step 2: Get all current challenge submission IDs
        let submissionIDs = await getCurrentChallengeSubmissionIDs()
        print("📊 Found \(submissionIDs.count) submissions to archive")

        // Step 3: Archive to CHALLENGEHISTORY
        let archived = await archiveChallengeHistory(prompt: currentPrompt, submissionIDs: submissionIDs)
        if !archived {
            await MainActor.run {
                self.lastResetStatus = "❌ Failed to archive challenge history"
                self.isResetting = false
            }
            return
        }

        print("✅ Archived challenge to history")

        // Step 4: Generate new prompt
        guard let newPrompt = await generateNewPrompt() else {
            await MainActor.run {
                self.lastResetStatus = "❌ Failed to generate new prompt"
                self.isResetting = false
            }
            return
        }

        print("✨ Generated new prompt: \(newPrompt)")

        // Step 5: Clear CURRENT_CHALLENGE_SUBMISSIONS
        let cleared = await clearCurrentSubmissions()
        if !cleared {
            await MainActor.run {
                self.lastResetStatus = "❌ Failed to clear current submissions"
                self.isResetting = false
            }
            return
        }

        print("🧹 Cleared current challenge submissions")

        // Step 6: Update current prompt
        let updated = await updateCurrentPrompt(newPrompt)
        if !updated {
            await MainActor.run {
                self.lastResetStatus = "❌ Failed to update current prompt"
                self.isResetting = false
            }
            return
        }

        print("✅ Weekly challenge reset complete!")

        await MainActor.run {
            self.lastResetStatus = "✅ Weekly reset complete! New prompt: \(newPrompt)"
            self.isResetting = false
        }
    }

    /// Get the current weekly challenge prompt
    private func getCurrentPrompt() async -> String? {
        do {
            let document = try await db.collection("weeklyChallenge").document("current").getDocument()
            if let data = document.data(), let prompt = data["prompt"] as? String {
                return prompt
            }
            // If no current prompt exists, return a default
            return "Create your best dish!"
        } catch {
            print("Error fetching current prompt: \(error.localizedDescription)")
            return nil
        }
    }

    /// Get all current challenge submission recipe IDs
    private func getCurrentChallengeSubmissionIDs() async -> [String] {
        do {
            let snapshot = try await db.collection("CURRENT_CHALLENGE_SUBMISSIONS").getDocuments()
            return snapshot.documents.map { $0.documentID }
        } catch {
            print("Error fetching current submissions: \(error.localizedDescription)")
            return []
        }
    }

    /// Archive current challenge to CHALLENGEHISTORY
    private func archiveChallengeHistory(prompt: String, submissionIDs: [String]) async -> Bool {
        do {
            let historyDoc: [String: Any] = [
                "prompt": prompt,
                "submissions": submissionIDs,
                "archivedAt": FieldValue.serverTimestamp(),
                "weekEnding": FieldValue.serverTimestamp()
            ]

            // Create a new document with auto-generated ID
            try await db.collection("CHALLENGEHISTORY").addDocument(data: historyDoc)
            return true
        } catch {
            print("Error archiving challenge history: \(error.localizedDescription)")
            return false
        }
    }

    /// Generate a new weekly challenge prompt using OpenAI
    private func generateNewPrompt() async -> String? {
        return await withCheckedContinuation { continuation in
            aiViewModel.suggestWeeklyChallenge { prompt in
                continuation.resume(returning: prompt)
            }
        }
    }

    /// Clear all documents from CURRENT_CHALLENGE_SUBMISSIONS
    private func clearCurrentSubmissions() async -> Bool {
        do {
            let snapshot = try await db.collection("CURRENT_CHALLENGE_SUBMISSIONS").getDocuments()

            // Delete all documents
            for document in snapshot.documents {
                try await db.collection("CURRENT_CHALLENGE_SUBMISSIONS").document(document.documentID).delete()
            }

            return true
        } catch {
            print("Error clearing current submissions: \(error.localizedDescription)")
            return false
        }
    }

    /// Update the current weekly challenge prompt
    private func updateCurrentPrompt(_ newPrompt: String) async -> Bool {
        do {
            try await db.collection("weeklyChallenge").document("current").setData([
                "prompt": newPrompt,
                "updatedAt": FieldValue.serverTimestamp()
            ])
            return true
        } catch {
            print("Error updating current prompt: \(error.localizedDescription)")
            return false
        }
    }

    /// Initialize the weekly challenge with a default prompt (call once)
    static func initializeWeeklyChallenge() async {
        let db = Firestore.firestore()
        let aiViewModel = AIViewModel()

        do {
            // Check if current challenge already exists
            let doc = try await db.collection("weeklyChallenge").document("current").getDocument()

            if !doc.exists {
                // Generate initial prompt
                let initialPrompt = await withCheckedContinuation { continuation in
                    aiViewModel.suggestWeeklyChallenge { prompt in
                        continuation.resume(returning: prompt ?? "Create your best comfort food dish!")
                    }
                }

                try await db.collection("weeklyChallenge").document("current").setData([
                    "prompt": initialPrompt,
                    "createdAt": FieldValue.serverTimestamp()
                ])

                print("✅ Initialized weekly challenge with prompt: \(initialPrompt)")
            } else {
                print("ℹ️ Weekly challenge already initialized")
            }
        } catch {
            print("Error initializing weekly challenge: \(error.localizedDescription)")
        }
    }
}
