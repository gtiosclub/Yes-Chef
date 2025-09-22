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
    case fruit(Fruit)
    
    enum Protein: String, CaseIterable {
        case chicken = "Chicken"
        case beef = "Beef"
        case salmon = "Salmon"
        case eggs = "Eggs"
        case tofu = "Tofu"
        case blackBeans = "Black Beans"
        case almonds = "Almonds"
        case shrimp = "Shrimp"
        case turkey = "Turkey"
        case pork = "Pork"
        case seitan = "Seitan" // wheat meat
        case kidneyBeans = "Kidney Beans"
        case pintoBeans = "Pinto Beans"
        case chickpeas = "Chickpeas"
        case tuna = "Tuna"
        case tilapia = "Tilapia"
        case crab = "Crab"
        case scallops = "Scallops"
        case cod = "Cod"
        case lobster = "Lobster"
        case duck = "Duck"
        case lamb = "Lamb"
        case venison = "Venison"
        case goat = "Goat"
        case bison = "Bison"
        case anchovies = "Anchovies"
        case sardines = "Sardines"
        case mackerel = "Mackerel"
        case clams = "Clams"
        case mussels = "Mussels"
        case oysters = "Oysters"
        case squid = "Squid"
        case octopus = "Octopus"
        case quail = "Quail"
        case rabbit = "Rabbit"
        case veal = "Veal"
        case halibut = "Halibut"
        case mahiMahi = "Mahi Mahi"
        case swordfish = "Swordfish"
        case snapper = "Snapper"
        case haddock = "Haddock"
        case trout = "Trout"
        case sardine = "Sardine"
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
        case kale = "Kale"
        case lettuce = "Lettuce"
        case arugula = "Arugula"
        case collardGreens = "Collard Greens"
        case cauliflower = "Cauliflower"
        case brusselsSprouts = "Brussels Sprouts"
        case cabbage = "Cabbage"
        case beets = "Beets"
        case parsnips = "Parsnips"
        case sweetPotatoes = "Sweet Potatoes"
        case turnips = "Turnips"
        case eggplant = "Eggplant"
        case zucchini = "Zucchini"
        case butternutSquash = "Butternut Squash"
        case acornSquash = "Acorn Squash"
        case spaghettiSquash = "Spaghetti Squash"
        case leeks = "Leeks"
        case greenBeans = "Green Beans"
        case asparagus = "Asparagus"
        case peas = "Peas"
        case cucumbers = "Cucumbers"
        case corn = "Corn"
        case celery = "Celery"
        case artichoke = "Artichoke"
        case fennel = "Fennel"
        case radishes = "Radishes"
        case bokChoy = "Bok Choy"
        case swissChard = "Swiss Chard"
        case mustardGreens = "Mustard Greens"
        case watercress = "Watercress"
        case okra = "Okra"
        case bambooShoots = "Bamboo Shoots"
        case lotusRoot = "Lotus Root"
        case daikon = "Daikon"
        case yucca = "Yucca"
        case taro = "Taro"
        case pumpkin = "Pumpkin"
        case jalapeno = "Jalapeño"
        case serrano = "Serrano"
        case habanero = "Habanero"
        case poblano = "Poblano"
        case chipotle = "Chipotle"
        case horseradish = "Horseradish"
        case gingerRoot = "Ginger Root"
        case turmericRoot = "Turmeric Root"
        case edamame = "Edamame"
        case nori = "Nori (Seaweed)"
        case kimchi = "Kimchi"
    }
    
    enum Grain: String, CaseIterable {
        case rice = "Rice"
        case pasta = "Pasta"
        case bread = "Bread"
        case potato = "Potato"
        case flour = "Flour"
        case jasmineRice = "Jasmine Rice"
        case basmatiRice = "Basmati Rice"
        case brownRice = "Brown Rice"
        case wildRice = "Wild Rice"
        case quinoa = "Quinoa"
        case barley = "Barley"
        case bulgur = "Bulgur"
        case farro = "Farro"
        case oats = "Oats"
        case cornTortillas = "Corn Tortillas"
        case millet = "Millet"
        case polenta = "Polenta"
        case plantains = "Plantains"
    }
    
    enum Dairy: String, CaseIterable {
        case milk = "Milk"
        case cheese = "Cheese"
        case butter = "Butter"
        case yogurt = "Yogurt"
        case cottageCheese = "Cottage Cheese"
        case greekYogurt = "Greek Yogurt"
        case cream = "Cream"
        case sourCream = "Sour Cream"
        case whippedCream = "Whipped Cream"
        case ghee = "Ghee"
        case kefir = "Kefir"
        case creamCheese = "Cream Cheese"
        case ricotta = "Ricotta"
        case mascarpone = "Mascarpone"
        case feta = "Feta"
        case goatCheese = "Goat Cheese"
        case blueCheese = "Blue Cheese"
        case brie = "Brie"
        case camembert = "Camembert"
        case parmesan = "Parmesan"
        case manchego = "Manchego"
        case edam = "Edam"
        case gouda = "Gouda"
        case provolone = "Provolone"
        case oatMilk = "Oat Milk"
        case almondMilk = "Almond Milk"
        case soyMilk = "Soy Milk"
        case coconutMilk = "Coconut Milk"
        case condensedMilk = "Condensed Milk"
        case evaporatedMilk = "Evaporated Milk"
    }
    
    enum Seasoning: String, CaseIterable {
        case salt = "Salt"
        case blackPepper = "Black Pepper"
        case oliveOil = "Olive Oil"
        case garlic = "Garlic"
        case lemon = "Lemon"
        case paprika = "Paprika"
        case chiliPowder = "Chili Powder"
        case cumin = "Cumin"
        case oregano = "Oregano"
        case basil = "Basil"
        case rosemary = "Rosemary"
        case thyme = "Thyme"
        case parsley = "Parsley"
        case soySauce = "Soy Sauce"
        case vinegar = "Vinegar"
        case ginger = "Ginger"
        case cinnamon = "Cinnamon"
        case nutmeg = "Nutmeg"
        case turmeric = "Turmeric"
        case coriander = "Coriander"
        case cardamom = "Cardamom"
        case cloves = "Cloves"
        case starAnise = "Star Anise"
        case fennelSeeds = "Fennel Seeds"
        case dill = "Dill"
        case mint = "Mint"
        case chives = "Chives"
        case sage = "Sage"
        case tarragon = "Tarragon"
        case curryPowder = "Curry Powder"
        case garamMasala = "Garam Masala"
        case fiveSpice = "Chinese Five Spice"
        case wasabi = "Wasabi"
        case miso = "Miso"
        case tahini = "Tahini"
        case sesameOil = "Sesame Oil"
        case fishSauce = "Fish Sauce"
        case hoisin = "Hoisin Sauce"
        case teriyaki = "Teriyaki Sauce"
        case sriracha = "Sriracha"
        case harissa = "Harissa"
        case mole = "Mole"
        case ketchup = "Ketchup"
        case mustard = "Mustard"
        case mayonnaise = "Mayonnaise"
        case hotSauce = "Hot Sauce"
        case barbecueSauce = "Barbecue Sauce"
    }
    
    enum Fruit: String, CaseIterable {
        case apple = "Apple"
        case banana = "Banana"
        case orange = "Orange"
        case lemonFruit = "Lemon (Fruit)"
        case lime = "Lime"
        case grapefruit = "Grapefruit"
        case mango = "Mango"
        case pineapple = "Pineapple"
        case papaya = "Papaya"
        case guava = "Guava"
        case passionFruit = "Passion Fruit"
        case kiwi = "Kiwi"
        case dragonFruit = "Dragon Fruit"
        case pomegranate = "Pomegranate"
        case figs = "Figs"
        case dates = "Dates"
        case raisins = "Raisins"
        case blueberries = "Blueberries"
        case strawberries = "Strawberries"
        case raspberries = "Raspberries"
        case blackberries = "Blackberries"
        case cherries = "Cherries"
        case peaches = "Peaches"
        case plums = "Plums"
        case pears = "Pears"
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
        case "fruit":
            return Fruit.allCases.map { .fruit($0) }
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
        ingredients.append(contentsOf: Fruit.allCases.map { .fruit($0) })

        return ingredients
    }
    
    static var ingredientsByCategory: [String: [Ingredient]] {
        var grouped: [String: [Ingredient]] = [:]
        grouped["Protein"] = Protein.allCases.map { .protein($0) }
        grouped["Vegetable"] = Vegetable.allCases.map { .vegetable($0) }
        grouped["Grain"] = Grain.allCases.map { .grain($0) }
        grouped["Dairy"] = Dairy.allCases.map { .dairy($0) }
        grouped["Seasoning"] = Seasoning.allCases.map { .seasoning($0) }
        grouped["Fruit"] = Fruit.allCases.map { .fruit($0) }
        
        return grouped
    }
}
