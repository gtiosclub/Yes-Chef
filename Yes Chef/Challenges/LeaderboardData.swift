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
        
        listener = db.collection("current_challenge_submissions")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error listening to leaderboard updates:", error?.localizedDescription ?? "unknown error")
                    return
                }
                
                // 💡 FIX 2: Added trimming for ID consistency (Crucial fix)
                let rawIDs = documents.map { $0.documentID }
                let recipeIDs = rawIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                //what if recipeIDs is empty aka no submissions
                guard !recipeIDs.isEmpty else {
                    Task { @MainActor in
                        self.currentLeaderboard.entries = []
                    }
                    return
                }
                
                self.db.collection("RECIPES") // 💡 FIX 3: Assuming your collection is lowercase 'recipes' (Standard Firebase practice)
                                              // If it MUST be 'RECIPES', change it back, but check Firebase casing.
                    .whereField(FieldPath.documentID(), in: recipeIDs)
                    .getDocuments { recipeSnapshot, recipeError in
                        
                        // --- All processing must be INSIDE this closure ---
                        
                        guard let recipeDocs = recipeSnapshot?.documents, recipeError == nil else {
                            print("Error fetching recipes:", recipeError?.localizedDescription ?? "unknown")
                            return
                        }
                        
                        var entries: [LeaderboardEntry] = []
                        
                        for (_, doc) in recipeDocs.enumerated() {
                            let data = doc.data()
                            let idString = doc.documentID
                            
                            // 💡 FIX 4: Corrected Mapping Issues
                            // Removed timestamp from the 'if let' check for now since it's commented out in the struct.
                            // Assuming 'userID' is the username for simplicity (denormalization)
                            if let username = data["userId"] as? String, // Assuming username is denormalized
                               let recipeName = data["name"] as? String, // Used 'name' per your snippet, not 'recipeName'
                               let likes = data["likes"] as? Int {
                                
                                // Optional timestamp mapping (only if available)
                                //let timestamp = data["datePosted"] as? Timestamp
                                
                                let user = UserTest(
                                    // Use 'userID' for the user's ID
                                    id: data["userId"] as? String ?? "",
                                    username: username,
                                    profileImageURL: data["profileImageURL"] as? String
                                )
                                
                                
                                let entry = LeaderboardEntry(
                                    id: idString,
                                    rank: 0,
                                    user: user,
                                    recipeName: recipeName,
                                    //datePosted: timestamp?.dateValue(), // Now safely optional
                                    likes: likes
                                )
                                
                                entries.append(entry)
                            } else {
                                // Add a debug message for skipped documents
                                print("⚠️ Skipping recipe \(idString): Missing username, name, or likes field.")
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
                                //datePosted: entries[i].datePosted,
                                likes: entries[i].likes
                            )
                        }
                        
                        Task { @MainActor in
                            self.currentLeaderboard.entries = entries
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
