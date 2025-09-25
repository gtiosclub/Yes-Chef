//
//  FirebaseTesting.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/11/25.
//

import SwiftUI
import Foundation
struct FirebaseTesting: View {
    @State private var recipeVM = RecipeVM()
    @State private var aiVM = AIViewModel()
    
    var body: some View {
        Section("Backend Methods") {
            Button("Test Create Recipe") {
                testCreateRecipe()
            }
        }
        
        Section("AI requests") {
            Button("Create Description") {
                Task {
                    let description = await aiVM.catchyDescription(title: "Rigatoni Vodka")
                    print(description ?? "No description generated.")
                }
            }
        }
    }
    
    private func testCreateRecipe() {
        let recipeID = recipeVM.createRecipe(
            userId: "test_user_123",
            name: "Chocolate Chip Cookies",
            ingredients: [
                "2 cups all-purpose flour",
                "1 cup butter, softened",
                "1 cup chocolate chips"
            ],
            allergens: ["Gluten", "Dairy"],
            tags: ["Dessert", "Baking", "Sweet"],
            steps: [
                "Preheat oven to 350°F",
                "Mix butter and sugars",
                "Add flour gradually",
                "Fold in chocolate chips",
                "Bake for 12-15 minutes"
            ],
            description: "Classic chocolate chip cookies that are crispy on the outside and chewy on the inside.",
            prepTime: 30,
            difficulty: Difficulty.easy,
            media: ["cookie_image_1.jpg"]
        )
        
        print("Recipe created with ID: \(recipeID)")
    }
}

#Preview {
    FirebaseTesting()
}
