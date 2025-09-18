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
    

    static var allCategories: [(String, [String])] {
        return [
            ("Proteins", Protein.allCases.map { $0.rawValue }),
            ("Vegetables", Vegetable.allCases.map { $0.rawValue }),
            ("Grains & Starches", Grain.allCases.map { $0.rawValue }),
            ("Dairy", Dairy.allCases.map { $0.rawValue }),
            ("Seasonings & Condiments", Seasoning.allCases.map { $0.rawValue })
        ]
    }
    
    static func getAllIngredients() -> [String] {
        return allCategories.flatMap { $0.1 }
    }
    
    static func getIngredientsFor(category: String) -> [String]? {
        return allCategories.first { $0.0 == category }?.1
    }
    
    static func getCategoryFor(ingredient: String) -> String? {
        for (categoryName, ingredients) in allCategories {
            if ingredients.contains(ingredient) {
                return categoryName
            }
        }
        return nil
    }
}
