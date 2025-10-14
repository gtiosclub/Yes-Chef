//
//  IngredientClass.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 10/14/25.
//
import Foundation

class IngredientClass: ObservableObject, Identifiable {
    
    let id = UUID()
    // MARK: - Properties
    @Published var name: String
    @Published var quantity: Int
    @Published var unit: String
    @Published var preparation: String

    // MARK: - Initializer
    init(name: String, quantity: Int, unit: String, preparation: String) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.preparation = preparation
    }
    init() {
        self.name = "name"
        self.quantity = 1
        self.unit = "measurement unit"
        self.preparation = "How to prepare"
    }
}
