//
//  FirebaseTesting.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/11/25.
//

import SwiftUI
import Foundation
struct FirebaseTesting: View {
    @State private var recipeVM = CreateRecipeVM()
    @State private var aiVM = AIViewModel()
    
    var body: some View {
        Section("Backend Methods") {
            Button("Test Create Recipe") {
                Task {
                    await testCreateRecipe()
                }
            }
            
            Button("Test Send Message") {
                Task {
                    recipeVM.name = "Pizza"
                    recipeVM.ingredients = [
                        Ingredient(name: "Tomato Sauce", quantity: 1, unit: "cup", preparation: "" ),
                        Ingredient(name: "Mozarella Cheese", quantity: 1, unit: "cup", preparation: ""),
                        Ingredient(name: "Pizza Dough", quantity: 1, unit: "serving", preparation: "" )
                    ]
                    recipeVM.servingSize = 1
                    recipeVM.description = "A classic Italian dish."
                    recipeVM.prepTimeInput = "10"
                    recipeVM.steps = ["Put sauce on dough.", "Add cheese.", "Bake for 20 minutes.", "Cut into wedges."]
                    
                    await recipeVM.sendToChef(userMessage: "make it vegan")
                }
            }
        }
        
        Section("AI requests") {
            Button("Create Description") {
                Task {
                    let description = await aiVM.catchyDescription(title: "Egg Salad Sandwhich")
                    print(description ?? "No description generated.")
                }
            }
            
        }
    }
    
    private func testCreateRecipe() async {
//        let recipeID = try await recipeVM.createRecipe(
//            userId: "test_user_123",
//            name: "Chocolate Chip Cookies",
//            ingredients: [
//                "2 cups all-purpose flour",
//                "1 cup butter, softened",
//                "1 cup chocolate chips"
//            ],
//            allergens: ["Gluten", "Dairy"],
//            tags: ["Dessert", "Baking", "Sweet"],
//            steps: [
//                "Preheat oven to 350°F",
//                "Mix butter and sugars",
//                "Add flour gradually",
//                "Fold in chocolate chips",
//                "Bake for 12-15 minutes"
//            ],
//            description: "Classic chocolate chip cookies that are crispy on the outside and chewy on the inside.",
//            prepTime: 30,
//            difficulty: Difficulty.easy,
//            media: ["cookie_image_1.jpg"]
//        )
        
//        print("Recipe created with ID: \(recipeID)")
    }
   
}

#Preview {
    FirebaseTesting()
}
