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

struct SmartSuggestionDemoView: View {
    @State private var msg = "Make it vegetarian and peanut-free."
    @State private var output = "—"

    let vm = AIViewModel()  

    var body: some View {
        VStack(spacing: 12) {
            Text("Smart Suggestion Demo").font(.headline)
            TextEditor(text: $msg).frame(height: 100).border(.secondary)
            Button("Run") {
                Task {
                    do {
                        let recipe = Recipe(
                            userId: "u1",
                            recipeId: "r1",
                            name: "Spicy Peanut Chicken Noodles",
                            ingredients: ["chicken thigh", "peanuts", "soy sauce", "noodles", "garlic", "chili oil"],
                            allergens: ["peanuts", "soy"],
                            tags: ["asian", "noodles"],
                            steps: ["Boil noodles", "Stir-fry chicken", "Toss with peanut sauce"],
                            description: "Weeknight spicy noodle bowl.",
                            prepTime: 25,
                            difficulty: .easy,
                            servingSize: 3,
                            media: [],
                            chefsNotes: "Notes go here..."
                        )

                        let s = try await vm.smartSuggestion(recipe: recipe, userMessage: msg)
                        output = """
                        MESSAGE:
                        \(s.message)

                        TOOLCALL:
                        \(s.toolcall.map { "\($0.item) | -\($0.removing.joined(separator: ", ")) +\($0.adding.joined(separator: ", "))" }.joined(separator: "\n"))
                        """
                        print(s)
                    } catch {
                        output = "Error: \(error)"
                        print(error)
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            ScrollView { Text(output).font(.system(.footnote, design: .monospaced)).frame(maxWidth: .infinity, alignment: .leading) }
                .frame(maxHeight: 240)
        }
        .padding()
    }
}

#Preview {
    SmartSuggestionDemoView()
}

