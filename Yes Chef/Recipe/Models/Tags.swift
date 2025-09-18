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

    // 🌍 Cuisines (~18)
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

    // 🍽️ Meal Types (~7)
    enum MealType: String, CaseIterable {
        case breakfast = "Breakfast"
        case brunch = "Brunch"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
        case dessert = "Dessert"
        case beverage = "Beverage"
    }

    // 🍱 Course (~10)
    enum Course: String, CaseIterable {
        case appetizer = "Appetizer"
        case side = "Side"
        case main = "Main"
        case soup = "Soup"
        case salad = "Salad"
        case sandwich = "Sandwich"
        case bread = "Bread"
        case sauce = "Sauce"
        case condiment = "Condiment"
        case drink = "Drink"
    }

    // 🥗 Dietary / Lifestyle (~12)
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

    // 🎯 Flavor profile (~11)
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

    // 👩‍🍳 Cooking method / technique (~14)
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

    // 📅 Occasion / vibe (~11)
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

    // ⏱️ Time/Effort (~6)
    enum Time: String, CaseIterable {
        case quick = "Quick (≤30m)"
        case weeknight = "Weeknight-Friendly"
        case makeAhead = "Make-Ahead"
        case onePot = "One-Pot"
        case fiveIngredients = "Five Ingredients"
        case budget = "Budget"
    }
}
