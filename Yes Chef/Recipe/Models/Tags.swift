//
//  Tags.swift
//  Yes Chef
//
//  Created by Neel Bhattacharyya on 9/18/25.
//

import Foundation

enum Tag: Hashable {
    case cuisine(Cuisine)
    case mealType(MealType)
    case course(Course)
    case dietary(Dietary)
    case flavor(Flavor)
    case method(Method)
    case occasion(Occasion)
    case time(Time)

    enum Cuisine: String, CaseIterable {
        case american = "American"
        case italian = "Italian"
        case mexican = "Mexican"
        case mediterranean = "Mediterranean"
        case indian = "Indian"
        case chinese = "Chinese"
        case japanese = "Japanese"
        case thai = "Thai"
        case korean = "Korean"
        case vietnamese = "Vietnamese"
        case french = "French"
        case greek = "Greek"
        case spanish = "Spanish"
        case middleEastern = "Middle Eastern"
        case turkish = "Turkish"
        case lebanese = "Lebanese"
        case caribbean = "Caribbean"
        case african = "African"
        case latinAmerican = "Latin American"
    }

    enum Course: String, CaseIterable {
        case breakfast = "Breakfast"
        case brunch = "Brunch"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
        case dessert = "Dessert"      
    }

    enum MealType: String, CaseIterable {
        case beverage = "Beverage"
        case appetizer = "Appetizer"
        case soup = "Soup"
        case salad = "Salad"
        case sandwich = "Sandwich"
        case sauce = "Sauce"
        case condiment = "Condiment"
    }

    enum Dietary: String, CaseIterable {
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case pescatarian = "Pescatarian"
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        case nutFree = "Nut-Free"
        case eggFree = "Egg-Free"
        case lowCarb = "Low-Carb"
        case highProtein = "High-Protein"
        case keto = "Keto"
        case paleo = "Paleo"
        case lowSodium = "Low-Sodium"
        case halal = "Halal"
        case kosher = "Kosher"
    }

    enum Flavor: String, CaseIterable {
        case spicy = "Spicy"
        case mild = "Mild"
        case sweet = "Sweet"
        case savory = "Savory"
        case tangy = "Tangy"
        case bitter = "Bitter"
        case smoky = "Smoky"
        case umami = "Umami"
        case salty = "Salty"
        case herby = "Herby"
        case citrusy = "Citrusy"
    }

    enum Method: String, CaseIterable {
        case grilled = "Grilled"
        case baked = "Baked"
        case fried = "Fried"
        case airFried = "Air-Fried"
        case roasted = "Roasted"
        case steamed = "Steamed"
        case stirFried = "Stir-Fried"
        case sautéed = "Sautéed"
        case braised = "Braised"
        case poached = "Poached"
        case slowCooked = "Slow-Cooked"
        case pressureCooked = "Pressure-Cooked"
        case smoked = "Smoked"
        case raw = "Raw"
    }

    enum Occasion: String, CaseIterable {
        case kidFriendly = "Kid-Friendly"
        case healthy = "Healthy"
        case comfortFood = "Comfort Food"
        case holiday = "Holiday"
        case gameDay = "Game Day"
        case picnic = "Picnic"
        case bbq = "BBQ"
        case mealPrep = "Meal Prep"
        case potluck = "Potluck"
        case romantic = "Romantic"
        case crowdPleaser = "Crowd-Pleaser"
    }

    enum Time: String, CaseIterable {
        case quick = "Quick (≤30m)"
        case weeknight = "Weeknight-Friendly"
        case makeAhead = "Make-Ahead"
        case onePot = "One-Pot"
        case fiveIngredients = "Five Ingredients"
        case budget = "Budget"
    }
    
    static var allCategories: [String] {
        return ["Cuisine", "Meal Type", "Course", "Dietary", "Flavor", "Method", "Occasion", "Time"]
    }
    
    static func allCases(for category: String) -> [Tag] {
        switch category.lowercased() {
        case "cuisine":
            return Cuisine.allCases.map { .cuisine($0) }
        case "meal type", "mealtype":
            return MealType.allCases.map { .mealType($0) }
        case "course":
            return Course.allCases.map { .course($0) }
        case "dietary":
            return Dietary.allCases.map { .dietary($0) }
        case "flavor":
            return Flavor.allCases.map { .flavor($0) }
        case "method":
            return Method.allCases.map { .method($0) }
        case "occasion":
            return Occasion.allCases.map { .occasion($0) }
        case "time":
            return Time.allCases.map { .time($0) }
        default:
            return []
        }
    }
    
    static var allTags: [Tag] {
        var tags: [Tag] = []
        tags.append(contentsOf: Cuisine.allCases.map { .cuisine($0) })
        tags.append(contentsOf: MealType.allCases.map { .mealType($0) })
        tags.append(contentsOf: Course.allCases.map { .course($0) })
        tags.append(contentsOf: Dietary.allCases.map { .dietary($0) })
        tags.append(contentsOf: Flavor.allCases.map { .flavor($0) })
        tags.append(contentsOf: Method.allCases.map { .method($0) })
        tags.append(contentsOf: Occasion.allCases.map { .occasion($0) })
        tags.append(contentsOf: Time.allCases.map { .time($0) })
        return tags
    }
    
    static var tagsByCategory: [String: [Tag]] {
        var grouped: [String: [Tag]] = [:]
        grouped["Cuisine"] = Cuisine.allCases.map { .cuisine($0) }
        grouped["Meal Type"] = MealType.allCases.map { .mealType($0) }
        grouped["Course"] = Course.allCases.map { .course($0) }
        grouped["Dietary"] = Dietary.allCases.map { .dietary($0) }
        grouped["Flavor"] = Flavor.allCases.map { .flavor($0) }
        grouped["Method"] = Method.allCases.map { .method($0) }
        grouped["Occasion"] = Occasion.allCases.map { .occasion($0) }
        grouped["Time"] = Time.allCases.map { .time($0) }
        return grouped
    }
}
