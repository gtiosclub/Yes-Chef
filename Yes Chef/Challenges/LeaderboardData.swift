import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

class LeaderboardData: ObservableObject {
    struct UserTest: Identifiable, Codable {
        let id: String            // Firebase UID or UUID
        let username: String
        let profileImageURL: String? // optional for avatars later
    }

    struct LeaderboardEntry: Identifiable, Codable {
        let id = UUID()
        let rank: Int
        let user: UserTest
        let recipeName: String
        let datePosted: Date
    }

    struct Leaderboard: Codable {
        var id: String // Firestore doc ID
        var weekStartDate: Date
        var entries: [LeaderboardEntry]
    }
    
    @Published var currentLeaderboard: Leaderboard = Leaderboard(
        id: UUID().uuidString,
        weekStartDate: Date(),
        entries: LeaderboardData.sampleEntries()
    )
    
    private var db = Firestore.firestore()
   

    
    // Add leaderboard using Firestore completion block
    func addLeaderboard() {
        db.enableNetwork { error in
            if let error = error {
                print("Failed to re-enable network:", error.localizedDescription)
            } else {
                print("Network re-enabled")
            }
        }
        // Convert Leaderboard to a dictionary
        let data: [String: Any] = [
            "id": self.currentLeaderboard.id,
            "weekStartDate": Timestamp(date: self.currentLeaderboard.weekStartDate),
            "entries": self.currentLeaderboard.entries.map { entry in
                return [
                    "id": entry.id.uuidString,
                    "rank": entry.rank,
                    "username": entry.user.username,
                    "recipeName": entry.recipeName,
                    "datePosted": Timestamp(date: entry.datePosted)
                ]
            }
        ]
        
        
        // Add to Firestore with completion block
        self.db.collection("history").document(self.currentLeaderboard.id).setData(data) { error in
            if let error = error {
                print("Error writing leaderboard:", error.localizedDescription)
            } else {
                print("Leaderboard written successfully!")
            }
        }
        
        
       
    }
    
    // Sample entries for testing
    static func sampleEntries() -> [LeaderboardEntry] {
        return (1...10).map { i in
            let user = UserTest(
                id: UUID().uuidString,
                username: "User \(i)",
                profileImageURL: nil
            )
            
            return LeaderboardEntry(
                rank: i,
                user: user,
                recipeName: "Recipe \(i)",
                datePosted: Date().addingTimeInterval(-Double(i) * 86400)
            )
        }
    }
    
    func resetLeaderboard() {
        self.currentLeaderboard.entries = []
    }
}
