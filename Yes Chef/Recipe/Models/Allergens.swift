//
//  Allergens.swift
//  Yes Chef
//
//  Created by Neel Bhattacharyya on 9/18/25.
//

import Foundation

enum Allergen: Hashable {
    case common(Common)
    case dairy(Dairy)
    case nuts(Nuts)
    case seafood(Seafood)
    case grain(Grain)
    case other(Other)

    // 🧑‍🤝‍🧑 General / Common Allergens
    enum Common: String, CaseIterable {
        case eggs = "Eggs"
        case soy = "Soy"
        case sesame = "Sesame"
    }

    // 🥛 Dairy Allergens
    enum Dairy: String, CaseIterable {
        case milk = "Milk"
        case cheese = "Cheese"
        case butter = "Butter"
        case yogurt = "Yogurt"
        case cream = "Cream"
        case whey = "Whey"
    }

    // 🌰 Nut Allergies
    enum Nuts: String, CaseIterable {
        case peanuts = "Peanuts"
        case almonds = "Almonds"
        case walnuts = "Walnuts"
        case cashews = "Cashews"
        case pecans = "Pecans"
        case hazelnuts = "Hazelnuts"
        case pistachios = "Pistachios"
        case macadamiaNuts = "Macadamia Nuts"
    }

    // 🐟 Seafood Allergies
    enum Seafood: String, CaseIterable {
        case fish = "Fish"
        case shellfish = "Shellfish"
        case shrimp = "Shrimp"
        case crab = "Crab"
        case lobster = "Lobster"
        case scallops = "Scallops"
        case clams = "Clams"
        case mussels = "Mussels"
        case oysters = "Oysters"
    }

    // 🌾 Grain / Gluten Allergens
    enum Grain: String, CaseIterable {
        case wheat = "Wheat"
        case barley = "Barley"
        case rye = "Rye"
        case oats = "Oats"
        case gluten = "Gluten"
    }

    // ➕ Other Allergens
    enum Other: String, CaseIterable {
        case mustard = "Mustard"
        case celery = "Celery"
        case sulfites = "Sulfites"
        case lupin = "Lupin"
    }
}
