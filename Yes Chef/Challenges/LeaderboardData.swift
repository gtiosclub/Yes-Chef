import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth


class LeaderboardData: ObservableObject {
    private var email = "emajithia3@gmail.com"
    private var password = "Jama7685!"
    
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
        var id: String // optional, can be Firestore doc ID
        var weekStartDate: Date
        var entries: [LeaderboardEntry]
    }
    
    @Published var currentLeaderboard: Leaderboard = Leaderboard(
        id: UUID().uuidString,
        weekStartDate: Date(),
        entries: LeaderboardData.sampleEntries()
    )
    
    private var db = Firestore.firestore()

    func signInIfNeeded(completion: @escaping (Bool) -> Void) {
            if Auth.auth().currentUser != nil {
                completion(true)
            } else {
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("Auth error:", error)
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    
    func addLeaderboard() {
            signInIfNeeded { success in
                guard success else { return }
                do {
                    try self.db.collection("leaderboards").addDocument(from: self.currentLeaderboard)
                    print("Leaderboard written successfully!")
                } catch {
                    print("Error writing leaderboard:", error)
                }
            }
        }
    

    static func sampleEntries() -> [LeaderboardEntry] {
        var entries: [LeaderboardEntry] = (1...10).map { i in
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
        return entries
    }
}
