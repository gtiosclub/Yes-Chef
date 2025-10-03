import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

@MainActor
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
        let likes: Int
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
    
    func recalibrateEntries(){
        // Fetch from Firebase after initialization
        fetchUserRecipes { entries in
            DispatchQueue.main.async {
                self.currentLeaderboard.entries = entries
            }
        }
    }
    
    func refreshData() async {
        while true{
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 seconds
            await MainActor.run {
                self.recalibrateEntries()
            }
        }
    }
    
    private var db = Firestore.firestore()
   

    
  /*  func addLeaderboard() {
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
        
        
       
    }*/
    
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
        
        db.collection("userRecipes")
            .order(by: "likes", descending: true) // order by likes
            .limit(to: 10) // only top 10
            .getDocuments { snapshot, error in
                
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
                
                for (index, doc) in documents.enumerated() {
                    let data = doc.data()
                    
                    if let idString = data["id"] as? String,
                       let username = data["username"] as? String,
                       let recipeName = data["recipeName"] as? String,
                       let timestamp = data["datePosted"] as? Timestamp,
                       let likes = data["likes"] as? Int {
                        
                        let user = UserTest(
                            id: idString,
                            username: username,
                            profileImageURL: data["profileImageURL"] as? String
                        )
                        
                        let entry = LeaderboardEntry(
                            id: UUID(uuidString: idString) ?? UUID(),
                            rank: index + 1,
                            user: user,
                            recipeName: recipeName,
                            datePosted: timestamp.dateValue(),
                            likes: likes      
                        )
                        
                        entries.append(entry)
                    }
                }
                
                completion(entries)
            }
    }
    
    static func seedRandomUserRecipes() {
        let db = Firestore.firestore()
        
        let usernames = [
            "Aiden", "Olivia", "Noah", "Emma", "Liam", "Sophia", "Mason", "Isabella", "Ethan", "Mia",
            "Logan", "Charlotte", "James", "Amelia", "Benjamin", "Harper", "Elijah", "Evelyn", "Alexander", "Abigail",
            "Michael", "Ella", "Daniel", "Elizabeth", "Henry", "Camila", "Jackson", "Luna", "Sebastian", "Sofia",
            "Jack", "Avery", "Owen", "Mila", "Samuel", "Aria", "Matthew", "Scarlett", "Joseph", "Penelope",
            "Levi", "Layla", "David", "Chloe", "John", "Victoria", "Wyatt", "Madison", "Carter", "Eleanor",
            "Julian", "Grace", "Luke", "Nora", "Grayson", "Riley", "Isaac", "Zoey", "Jayden", "Hannah",
            "Theodore", "Hazel", "Gabriel", "Lily", "Anthony", "Ellie", "Dylan", "Violet", "Leo", "Aurora",
            "Lincoln", "Savannah", "Jaxon", "Audrey", "Asher", "Brooklyn", "Christopher", "Bella", "Josiah", "Claire",
            "Andrew", "Skylar", "Thomas", "Lucy", "Joshua", "Paisley", "Ezra", "Everly", "Hudson", "Anna",
            "Charles", "Caroline", "Caleb", "Nova", "Isaiah", "Genesis", "Ryan", "Emilia", "Nathan", "Kennedy"
        ]
        
        let recipes = [
            "Classic Spaghetti Carbonara", "Thai Green Curry with Jasmine Rice", "Mediterranean Chickpea Salad",
            "Slow-Cooked Beef Bourguignon", "Homemade Margherita Pizza", "Japanese Ramen with Pork Belly",
            "Grilled Salmon with Lemon Dill Sauce", "Indian Butter Chicken with Naan", "Vegetarian Stuffed Peppers",
            "Korean Bibimbap Bowl", "French Onion Soup with Gruyère", "Moroccan Chicken Tagine",
            "Cajun Shrimp Tacos with Slaw", "Falafel Wrap with Tahini Sauce", "Teriyaki Chicken Stir-Fry",
            "Quinoa and Black Bean Chili", "Homemade Sushi Rolls", "Eggplant Parmesan Casserole",
            "BBQ Pulled Pork Sandwiches", "Vegan Lentil Shepherd’s Pie",
            "Greek Gyros with Tzatziki", "Chicken Alfredo Fettuccine", "Roasted Butternut Squash Soup",
            "Spanish Paella with Seafood", "Lobster Mac and Cheese", "Avocado Toast with Poached Eggs",
            "Buffalo Cauliflower Bites", "Mediterranean Hummus Platter", "Baked Ziti with Sausage",
            "Thai Peanut Noodle Salad", "Stuffed Portobello Mushrooms", "Homemade Gnocchi with Pesto",
            "Chicken and Waffles with Maple Syrup", "Jamaican Jerk Chicken with Rice and Peas",
            "Vegetable Tempura with Dipping Sauce", "French Quiche Lorraine", "Beef Tacos with Fresh Salsa",
            "Korean Bulgogi Beef", "Rustic Ratatouille", "Crispy Fish and Chips", "Mushroom Risotto",
            "Pho Bo (Vietnamese Beef Noodle Soup)", "Shakshuka with Feta", "Pulled Jackfruit Sandwiches",
            "Sweet Potato and Black Bean Enchiladas", "Chicken Satay Skewers with Peanut Sauce",
            "Greek Spanakopita", "Stuffed Cabbage Rolls", "Peking Duck Pancakes", "Italian Minestrone Soup",
            "Beef Stroganoff with Egg Noodles", "Fried Rice with Shrimp", "Vegan Buddha Bowl",
            "Clam Chowder in Bread Bowl", "Stuffed Acorn Squash", "Shredded Chicken Quesadillas",
            "Lamb Rogan Josh", "Japanese Okonomiyaki", "Seared Scallops with Garlic Butter",
            "Vegetable Lasagna", "BBQ Ribs with Cornbread", "Sesame Crusted Tuna Steaks",
            "Katsu Curry with Rice", "Chimichurri Steak", "Honey Garlic Glazed Carrots",
            "French Croque Monsieur", "Chicken Cordon Bleu", "Pasta Primavera", "Shrimp Scampi with Linguine",
            "Vegetarian Pad Thai", "Beef Empanadas", "Persian Chicken Kabobs", "Stuffed Zucchini Boats",
            "Homemade Pierogi with Potato Filling", "Creamy Tomato Basil Soup", "Korean Kimchi Stew (Kimchi Jjigae)",
            "Coconut Curry Lentil Soup", "Southern Biscuits and Gravy", "Salmon Poke Bowl", "Vegetarian Falafel Burger",
            "Gnocchi alla Sorrentina", "Indian Paneer Tikka Masala", "New York Cheesecake", "Baklava with Honey Syrup",
            "Tres Leches Cake", "Tiramisu with Espresso", "Mango Sticky Rice", "French Crème Brûlée",
            "Carrot Cake with Cream Cheese Frosting", "Pavlova with Fresh Berries", "Molten Chocolate Lava Cake",
            "Churros with Chocolate Sauce", "Lemon Meringue Pie", "Strawberry Shortcake", "Banoffee Pie",
            "Peach Cobbler", "Pumpkin Pie with Whipped Cream", "Pineapple Upside-Down Cake", "Classic Apple Strudel"
        ]
        
        for i in 1...50 {
            let id = UUID().uuidString
            let username = usernames.randomElement()! + "\(Int.random(in: 1...999))"
            let recipeName = recipes.randomElement()!
            let likes = Int.random(in: 0...2000)
            let timestamp = Timestamp(date: Date().addingTimeInterval(Double.random(in: -2_000_000...0)))
            
            let data: [String: Any] = [
                "id": id,
                "username": username,
                "recipeName": recipeName,
                "likes": likes,
                "datePosted": timestamp,
                "profileImageURL": "https://picsum.photos/200?random=\(Int.random(in: 1...10_000))"
            ]
            
            db.collection("userRecipes").document(id).setData(data) { error in
                if let error = error {
                    print("Error writing recipe \(i): \(error.localizedDescription)")
                } else {
                    print("Recipe \(i) written successfully")
                }
            }
        }
    }

    
    static func clearUserRecipes() {
        let db = Firestore.firestore()
        db.collection("userRecipes").getDocuments { (snapshot, error) in
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
}
