//
//  populateRemixRecipeVM.swift
//  Yes Chef
//
//  Created by Yifan Wang on 10/2/25.
//
import Firebase
import FirebaseFirestore

private let db = Firestore.firestore()

struct RecipeModel: Identifiable {
    var id: String
    var name: String
    var description: String
    var ingredients: [String]
    var difficulty: String
    var allergens: [String]
    var prepTime: Int
    var media: [String]
    var steps: [String]
}

func fetchRecipeById(_ recipeId: String, completion: @escaping (RecipeModel?) -> Void) {
    db.collection("RECIPES").document(recipeId).getDocument { doc, error in
        if let error = error { print("Fetch error:", error.localizedDescription); completion(nil); return }
        guard let doc = doc, doc.exists, let data = doc.data() else { completion(nil); return }
        let r = RecipeModel(
            id: doc.documentID,
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            ingredients: data["ingredients"] as? [String] ?? [],
            difficulty: data["difficulty"] as? String ?? "",
            allergens: data["allergens"] as? [String] ?? [],
            prepTime: data["prepTime"] as? Int ?? 0,
            media: data["media"] as? [String] ?? [],
            steps: data["steps"] as? [String] ?? []
        )
        completion(r)
    }
}
