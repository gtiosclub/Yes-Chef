////
////  AItest.swift
////  Yes Chef
////
////  Created by Neel Bhattacharyya on 10/9/25.
////
//

//  AItest.swift
//  Yes Chef
//
//  Created by Neel Bhattacharyya on 10/9/25.
//

import SwiftUI

struct SmartSuggestionAltDemoView: View {
    @State private var msg = "Make it dairy-free and shellfish-free but keep it creamy. Update steps if needed."
    @State private var output = "—"
    let vm = AIViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Text("Smart Suggestion Demo (Alt)").font(.headline)

            TextEditor(text: $msg)
                .frame(height: 100)
                .border(.secondary)

            Button("Run") {
                Task {
                    do {
                        let recipe = Recipe(
                            userId: "u1",
                            recipeId: "r2",
                            name: "Creamy Shrimp Alfredo Pasta",
                            ingredients: [
                                Ingredient(name: "fettuccine", quantity: 8, unit: "oz", preparation: ""),
                                Ingredient(name: "shrimp", quantity: 1, unit: "lb", preparation: "peeled and deveined"),
                                Ingredient(name: "butter", quantity: 4, unit: "tbsp", preparation: ""),
                                Ingredient(name: "heavy cream", quantity: 1, unit: "cup", preparation: ""),
                                Ingredient(name: "parmesan", quantity: 1, unit: "cup", preparation: "grated"),
                                Ingredient(name: "garlic", quantity: 3, unit: "cloves", preparation: "minced"),
                                Ingredient(name: "salt", quantity: 1, unit: "tsp", preparation: ""),
                                Ingredient(name: "black pepper", quantity: 1, unit: "tsp", preparation: ""),
                                Ingredient(name: "parsley", quantity: 2, unit: "tbsp", preparation: "chopped")
                            ],
                            allergens: ["shellfish", "dairy"],
                            tags: ["italian","pasta","weeknight"],
                            steps: [
                                "Boil fettuccine until al dente.",
                                "Sauté shrimp in butter until pink.",
                                "Make sauce with butter, heavy cream, garlic, and parmesan.",
                                "Toss pasta with sauce and shrimp. Season with salt and pepper.",
                                "Garnish with parsley and serve."
                            ],
                            description: "Rich, classic Alfredo with shrimp.",
                            prepTime: 30,
                            difficulty: .medium,
                            servingSize: 2,
                            media: [],
                            chefsNotes: "No notes"
                        )

                        let s = try await vm.smartSuggestion(recipe: recipe, userMessage: msg)

                        let lines = s.toolcall.map { tool in
                            let removingStr = tool.removing.joined(separator: ", ")
                            
                            let addingStr = tool.adding.map { item in
                                switch item {
                                case .string(let str):
                                    return str
                                case .ingredient(let ing):
                                    let prep = ing.preparation.isEmpty ? "" : " (\(ing.preparation))"
                                    return "\(ing.quantity) \(ing.unit) \(ing.name)\(prep)"
                                }
                            }.joined(separator: ", ")
                            
                            return "\(tool.item) | -\(removingStr) +\(addingStr)"
                        }.joined(separator: "\n")

                        output = """
                        MESSAGE:
                        \(s.message)

                        TOOLCALL:
                        \(lines)
                        """
                    } catch {
                        output = "Error: \(error)"
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            ScrollView {
                Text(output)
                    .font(.system(.footnote, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 260)
        }
        .padding()
    }
}


#Preview {
    SmartSuggestionAltDemoView()
}

