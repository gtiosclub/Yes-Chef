//
//  CreateRecipeVM+Remix.swift
//  Yes Chef
//
//  Created by Yifan Wang on 10/14/25.
//
import Foundation
import SwiftUI

extension CreateRecipeVM {
    /// Build a prefilled VM from an existing Recipe for the Remix flow.
    static func from(recipe: Recipe) -> CreateRecipeVM {
        let vm = CreateRecipeVM()

        // Basics
        vm.name = recipe.name + " (Remix)"
        vm.description = recipe.description
        vm.prepTimeInput = String(recipe.prepTime)
        vm.difficulty = recipe.difficulty
        vm.servingSize = recipe.servingSize
        vm.steps = recipe.steps
        vm.chefsNotes = recipe.chefsNotes

        // Ingredients -> selectedIngredients
        vm.selectedIngredients = recipe.ingredients.map { ing in
            if let predefined = Ingredient.allIngredients.first(where: {
                $0.displayName.caseInsensitiveCompare(ing.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame
            }) {
                return .predefined(predefined)
            } else {
                return .custom(ing.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }

        // Allergens -> selectedAllergens
        vm.selectedAllergens = recipe.allergens.map { al in
            if let predefined = Allergen.allCases.first(where: {
                $0.displayName.caseInsensitiveCompare(al.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame
            }) {
                return .predefined(predefined)
            } else {
                return .custom(al.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }

        // Tags -> selectedTags
        vm.selectedTags = recipe.tags.map { tag in
            if let predefined = Tag.allTags.first(where: {
                $0.displayName.caseInsensitiveCompare(tag.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame
            }) {
                return .predefined(predefined)
            } else {
                return .custom(tag.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }

        // Media note:
        // Your Create flow uploads from local files (vm.localMediaPaths).
        // We cannot prefill remote URLs directly here.
        // (Optional) You can later download recipe.media to temp files and append to vm.localMediaPaths.

        return vm
    }
}

