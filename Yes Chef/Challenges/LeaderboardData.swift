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
        let id: UUID
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
    
    @Published var currentLeaderboard: Leaderboard
    
    init() {
        self.currentLeaderboard = Leaderboard(
            id: UUID().uuidString,
            weekStartDate: Date(),
            entries: [] // start empty
        )
        
        // Fetch from Firebase after initialization
        fetchUserRecipes { entries in
            DispatchQueue.main.async {
                self.currentLeaderboard.entries = entries
            }
        }
    }
    
    private var db = Firestore.firestore()
   

    
    func addLeaderboard() {
        db.enableNetwork { error in
            if let error = error {
                print("Failed to re-enable network:", error.localizedDescription)
            } else {
                print("Network re-enabled")
            }
        }

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
        
        
        self.db.collection("history").document(self.currentLeaderboard.id).setData(data) { error in
            if let error = error {
                print("Error writing leaderboard:", error.localizedDescription)
            } else {
                print("Leaderboard written successfully!")
            }
        }
        
        
       
    }
    
   /* static func sampleEntries() -> [LeaderboardEntry] {
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
    }*/
    
    
    func fetchUserRecipes(completion: @escaping ([LeaderboardEntry]) -> Void) {
        db.collection("userRecipes").getDocuments { snapshot, error in
            var entries: [LeaderboardEntry] = []
            
            if let error = error {
                print("Error fetching user recipes:", error.localizedDescription)
                completion(entries)
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(entries)
                return
            }
            
            for doc in documents {
                let data = doc.data()
                
                if let idString = data["id"] as? String,
                   let username = data["username"] as? String,
                   let rank = data["rank"] as? Int,
                   let recipeName = data["recipeName"] as? String,
                   let timestamp = data["datePosted"] as? Timestamp {
                    
                    let user = UserTest(
                        id: idString,
                        username: username,
                        profileImageURL: data["profileImageURL"] as? String
                    )
                    
                    let entry = LeaderboardEntry(
                        id: UUID(uuidString: idString) ?? UUID(),
                        rank: rank,
                        user: user,
                        recipeName: recipeName,
                        datePosted: timestamp.dateValue()
                    )
                    
                    entries.append(entry)
                }
            }
            
            completion(entries)
        }
    }
}
