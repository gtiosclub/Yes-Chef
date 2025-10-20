//
//  IngredientClass.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 10/14/25.
//
import Foundation
import Observation

@Observable class Ingredient: Codable, Identifiable {
    let id = UUID()
    var name: String
    var quantity: Int
    var unit: String
    var preparation: String

    init(name: String = "", quantity: Int = 0, unit: String = "", preparation: String = "") {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.preparation = preparation
    }
}
