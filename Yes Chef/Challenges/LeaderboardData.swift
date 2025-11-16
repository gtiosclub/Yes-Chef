import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

@MainActor
class LeaderboardData: ObservableObject {
    struct UserTest: Identifiable, Codable {
        let id: String
        let username: String
        let profileImageURL: String?
    }
    
    struct LeaderboardEntry: Identifiable, Codable {
        let id: String
        let rank: Int
        let user: UserTest
        let recipeName: String
        //let datePosted: Date? // 💡 FIX 1: Make Date optional since it's sometimes commented out
        let likes: Int
    }
    
    struct Leaderboard: Codable {
        var id: String
        var weekStartDate: Date
        var entries: [LeaderboardEntry]
    }
    
    @Published var currentLeaderboard: Leaderboard
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration? = nil
    
    init() {
        self.currentLeaderboard = Leaderboard(
            id: UUID().uuidString,
            weekStartDate: Date(),
            entries: []
        )
        // Ensure Firebase is initialized elsewhere!
        fetchUserRecipes()
    }
    
    func fetchUserRecipes() {
        listener?.remove()

        listener = db.collection("CURRENT_CHALLENGE_SUBMISSIONS")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error listening to leaderboard updates:", error?.localizedDescription ?? "unknown error")
                    return
                }
                let rawIDs = documents.map { $0.documentID }
                let recipeIDs = rawIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                //what if recipeIDs is empty aka no submissions
                guard !recipeIDs.isEmpty else {
                    Task { @MainActor in
                        self.currentLeaderboard.entries = []
                    }
                    return
                }
                
                self.db.collection("RECIPES") 
                    .whereField(FieldPath.documentID(), in: recipeIDs)
                    .getDocuments { recipeSnapshot, recipeError in
                        
                        // --- All processing must be INSIDE this closure ---
                        
                        guard let recipeDocs = recipeSnapshot?.documents, recipeError == nil else {
                            print("Error fetching recipes:", recipeError?.localizedDescription ?? "unknown")
                            return
                        }
                        
                        var entries: [LeaderboardEntry] = []

                        // Create a task group to fetch all user data concurrently
                        Task {
                            await withTaskGroup(of: LeaderboardEntry?.self) { group in
                                for doc in recipeDocs {
                                    let data = doc.data()
                                    let idString = doc.documentID

                                    group.addTask {
                                        guard let userId = data["userId"] as? String,
                                              let recipeName = data["name"] as? String,
                                              let likes = data["likes"] as? Int else {
                                            print("⚠️ Skipping recipe \(idString): Missing userId, name, or likes field.")
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

                                        let user = UserTest(
                                            id: userId,
                                            username: username,
                                            profileImageURL: profileImageURL
                                        )

                                        return LeaderboardEntry(
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
                                        entries.append(entry)
                                    }
                                }
                            }

                            // Sort by likes descending, then assign ranks
                            entries.sort { $0.likes > $1.likes }

                            for i in entries.indices {
                                // Assign rank after sorting
                                entries[i] = LeaderboardEntry(
                                    id: entries[i].id,
                                    rank: i + 1,
                                    user: entries[i].user,
                                    recipeName: entries[i].recipeName,
                                    likes: entries[i].likes
                                )
                            }

                            await MainActor.run {
                                self.currentLeaderboard.entries = entries
                            }
                        }
                    } // END of getDocuments (INNER) CLOSURE
                
            } // END of addSnapshotListener (OUTER) CLOSURE
    }
    
    // The rest of the class (clearUserRecipes and recalibrateEntries)
    static func clearUserRecipes() {
        print("Function started")
        let db = Firestore.firestore()
        db.collection("userRecipes").getDocuments { (snapshot, error) in
            print("Listener fired")
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for doc in documents {
                db.collection("userRecipes").document(doc.documentID).delete { err in
                    if let err = err {
                        print("Error deleting document \(doc.documentID): \(err.localizedDescription)")
                    } else {
                        print("Deleted document \(doc.documentID)")
                    }
                }
            }
        }
    }
    
    func recalibrateEntries(){
        fetchUserRecipes ()
    }
}
