//
//  CreateRecipeScreenVM.swift
//  Yes Chef
//
//  Created by Anushka Jain on 10/7/25.
//

import Foundation
import SwiftUI

final class CreateRecipeScreenVM: ObservableObject {
    @Published var userIdInput: String = ""
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var ingredientsInput: String = ""
    @Published var allergensInput: String = ""
    @Published var tagsInput: String = ""
    @Published var prepTimeInput: String = ""
    @Published var difficulty: Difficulty = .easy
    @Published var steps: [String] = [""]
    @Published var mediaInputs: [String] = [""]

    @Published private(set) var ingredients: [String] = []
    @Published private(set) var allergens: [String] = []
    @Published private(set) var tags: [String] = []

    private func normalizedArray(from text: String) -> [String] {
        text.split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func onIngredientsChanged(_ text: String) { ingredientsInput = text; ingredients = normalizedArray(from: text) }
    func onAllergensChanged(_ text: String)  { allergensInput  = text; allergens  = normalizedArray(from: text) }
    func onTagsChanged(_ text: String)       { tagsInput       = text; tags       = normalizedArray(from: text) }

    var prepTime: Int { Int(prepTimeInput) ?? 0 }

    func applyChanges(item: String, removing: [String], adding: [String]) {
        switch item.lowercased() {
        case "title":
            if let newTitle = adding.first { name = newTitle }
        case "ingredients":
            var set = Set(ingredients.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            let removingKeys = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            var next = ingredients.filter { !removingKeys.contains($0.lowercased()) }
            for add in adding {
                let key = add.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if !set.contains(key) { next.append(add); set.insert(key) }
            }
            ingredients = next
            ingredientsInput = next.joined(separator: ", ")
        case "allergens":
            var set = Set(allergens.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            let removingKeys = Set(removing.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            var next = allergens.filter { !removingKeys.contains($0.lowercased()) }
            for add in adding {
                let key = add.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if !set.contains(key) { next.append(add); set.insert(key) }
            }
            allergens = next
            allergensInput = next.joined(separator: ", ")
        default:
            break
        }
    }
}
