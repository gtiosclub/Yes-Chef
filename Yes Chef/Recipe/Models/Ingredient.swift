//
//  IngredientClass.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 10/14/25.
//
import Foundation
import Observation



@Observable class Ingredient: Codable, Identifiable, Hashable {
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
    
    enum CodingKeys: String, CodingKey {
        case name, quantity, unit, preparation
    }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        unit = try container.decode(String.self, forKey: .unit)
        preparation = try container.decode(String.self, forKey: .preparation)
        
        if let intQuantity = try? container.decode(Int.self, forKey: .quantity) {
            quantity = intQuantity
        } else if let doubleQuantity = try? container.decode(Double.self, forKey: .quantity) {
            quantity = Int(doubleQuantity)
        } else {
            throw DecodingError.typeMismatch(
                Int.self,
                DecodingError.Context(
                    codingPath: container.codingPath + [CodingKeys.quantity],
                    debugDescription: "Expected Int or Double for quantity"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(unit, forKey: .unit)
        try container.encode(preparation, forKey: .preparation)
    }
    
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name.lowercased())
    }
}

extension Ingredient: SearchableOption {
    var displayName: String { name }
}
