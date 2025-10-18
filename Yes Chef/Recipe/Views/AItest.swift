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
                                "fettuccine", "shrimp", "butter", "heavy cream",
                                "parmesan", "garlic", "salt", "black pepper", "parsley"
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
                            media: []
                        )

                        let s = try await vm.smartSuggestion(recipe: recipe, userMessage: msg)

                        // Pretty-print
                        let lines = s.toolcall.map {
                            "\($0.item) | -\($0.removing.joined(separator: ", ")) +\($0.adding.joined(separator: ", "))"
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
