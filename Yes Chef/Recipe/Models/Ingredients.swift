//
//  Recipe.swift
//  Yes Chef
//
//  Created by Sam Orouji on 9/17/25.
//

import Foundation

enum Ingredient: Hashable {
    case protein(Protein)
    case vegetable(Vegetable)
    case grain(Grain)
    case dairy(Dairy)
    case seasoning(Seasoning)
    
    enum Protein: String, CaseIterable {
        case chicken = "Chicken"
        case beef = "Beef"
        case salmon = "Salmon"
        case eggs = "Eggs"
        case tofu = "Tofu"
        case blackBeans = "Black Beans"
        case almonds = "Almonds"
        case shrimp = "Shrimp"
    }
    
    enum Vegetable: String, CaseIterable {
        case onion = "Onion"
        case garlic = "Garlic"
        case tomato = "Tomato"
        case bellPepper = "Bell Pepper"
        case spinach = "Spinach"
        case broccoli = "Broccoli"
        case carrots = "Carrots"
        case mushrooms = "Mushrooms"
    }
    
    enum Grain: String, CaseIterable {
        case rice = "Rice"
        case pasta = "Pasta"
        case bread = "Bread"
        case potato = "Potato"
        case flour = "Flour"
    }
    
    enum Dairy: String, CaseIterable {
        case milk = "Milk"
        case cheese = "Cheese"
        case butter = "Butter"
        case yogurt = "Yogurt"
    }
    
    enum Seasoning: String, CaseIterable {
        case salt = "Salt"
        case blackPepper = "Black Pepper"
        case oliveOil = "Olive Oil"
        case garlic = "Garlic"
        case lemon = "Lemon"
    }
    
    static var allCategories: [String] {
        return ["Protein", "Vegetable", "Grain", "Dairy", "Seasoning"]
    }
    
    static func allCases(for category: String) -> [Ingredient] {
        switch category.lowercased() {
        case "protein":
            return Protein.allCases.map { .protein($0) }
        case "vegetable":
            return Vegetable.allCases.map { .vegetable($0) }
        case "grain":
            return Grain.allCases.map { .grain($0) }
        case "dairy":
            return Dairy.allCases.map { .dairy($0) }
        case "seasoning":
            return Seasoning.allCases.map { .seasoning($0) }
        default:
            return []
        }
    }
    
    static var allIngredients: [Ingredient] {
        var ingredients: [Ingredient] = []
        ingredients.append(contentsOf: Protein.allCases.map { .protein($0) })
        ingredients.append(contentsOf: Vegetable.allCases.map { .vegetable($0) })
        ingredients.append(contentsOf: Grain.allCases.map { .grain($0) })
        ingredients.append(contentsOf: Dairy.allCases.map { .dairy($0) })
        ingredients.append(contentsOf: Seasoning.allCases.map { .seasoning($0) })
        return ingredients
    }
    
    static var ingredientsByCategory: [String: [Ingredient]] {
        var grouped: [String: [Ingredient]] = [:]
        grouped["Protein"] = Protein.allCases.map { .protein($0) }
        grouped["Vegetable"] = Vegetable.allCases.map { .vegetable($0) }
        grouped["Grain"] = Grain.allCases.map { .grain($0) }
        grouped["Dairy"] = Dairy.allCases.map { .dairy($0) }
        grouped["Seasoning"] = Seasoning.allCases.map { .seasoning($0) }
        return grouped
    }
}
