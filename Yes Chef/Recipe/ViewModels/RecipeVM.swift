//
//  RecipeVM.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/18/25.
//

import Foundation
import Observation
import FirebaseFirestore

@Observable class RecipeVM  {
    
    enum Difficulty {
            case easy
            case medium
            case hard
        }
    func createRecipe(userId: String, name: String, ingredients: [String], allergens: [String],tags: [String], steps: [String], description: String, prepTime: Int, difficulty: Difficulty, media:[String]) -> String {
        
        let recipeID = UUID()
        let recipeUUID = recipeID.uuidString

        let db = Firestore.firestore()
        let data: [String: Any] = [
            "userId" : userId,
            "name" : name,
            "ingredients" : ingredients,
            "allergens" : allergens,
            "tags" : tags,
            "steps" : steps,
            "description" : description,
            "prepTime" : prepTime,
            "difficulty": difficulty,
            "media" : media
        ]
        db.collection("RECIPES").document(recipeUUID).setData(data) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added successfully!")
            }
        }

        return recipeUUID;
    }
    
    
}
