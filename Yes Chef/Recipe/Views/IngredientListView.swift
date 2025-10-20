//
//  IngredientListView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 10/14/25.
//

import SwiftUI

struct IngredientListView: View {
    @State private var ingredients = [
        IngredientClass(name: "Flour", quantity: 2, unit: "cups", preparation: "sifted"),
        IngredientClass(name: "Sugar", quantity: 1, unit: "cup", preparation: "granulated")
    ]
    
    var body: some View {
        VStack {
            ForEach(Array(ingredients.enumerated()), id: \.element.id) { i, ingredient in
                IngredientCardView(ingredient: $ingredients[i]) {
                    ingredients.remove(at: i)
                }
            }
            
            HStack {
                Spacer()
                Button {
                    ingredients.append(IngredientClass())
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 40, height: 40)
                        .padding(2)
                        .background(Color(hex: "#ffa94a"))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .padding(.horizontal)
    }
}

struct IngredientCardView: View {
    @Binding var ingredient: IngredientClass
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                Text("Name")
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 90, alignment: .leading)
                    .foregroundStyle(Color(hex: "#453736"))
                TextField("name", text: $ingredient.name)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "#453736"))

            }
            
            HStack(spacing: 16) {
                Text("Quantity")
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 90, alignment: .leading)
                    .foregroundStyle(Color(hex: "#453736"))
                TextField("##", text: Binding(
                    get: { String(ingredient.quantity) },
                    set: { ingredient.quantity = Int($0) ?? 0 }
                ))
                .font(.system(size: 16))
                .keyboardType(.numberPad)
                .foregroundStyle(Color(hex: "#453736"))

            }
            
            HStack(spacing: 16) {
                Text("Unit")
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 90, alignment: .leading)
                    .foregroundStyle(Color(hex: "#453736"))
                
                TextField("measurement", text: $ingredient.unit)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "#453736"))

            }
            
            HStack(spacing: 16) {
                Text("Preparation")
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 90, alignment: .leading)
                    .foregroundStyle(Color(hex: "#453736"))
                TextField("how to prepare", text: $ingredient.preparation)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "#453736"))
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
                .padding(.horizontal, -10)
        
            Button(action: onRemove) {
                Text("Remove")
                    .foregroundColor(Color(hex: "#FF3F49"))
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.black, lineWidth: 1)
        )
        .padding(.vertical, 4)
    }
}


#Preview {
    IngredientListView()
}
