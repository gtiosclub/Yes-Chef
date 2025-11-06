//
//  IngredientListView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 10/14/25.
//

import SwiftUI

struct AddIngredients: View {
    @Binding var ingredients: [Ingredient]
    var previewRemoving: [String] = []
    var previewAdding: [Ingredient] = []
    
    private func isRemoving(_ ingredient: Ingredient) -> Bool {
        previewRemoving.contains { removing in
            ingredient.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == removing.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    var body: some View {
        VStack {
            ForEach(Array(ingredients.enumerated()), id: \.element.id) { i, ingredient in
                IngredientCardView(
                    ingredient: $ingredients[i],
                    isRemoving: isRemoving(ingredient)
                ) {
                    ingredients.remove(at: i)
                }
            }
            
            // Show preview additions
            ForEach(previewAdding, id: \.id) { ingredient in
                IngredientCardView(
                    ingredient: .constant(ingredient),
                    isAdding: true
                ) {
                    // Preview items can't be removed
                }
            }
            
            HStack {
                Spacer()
                Button {
                    ingredients.append(Ingredient())
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 25, weight: .bold))
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
    @Binding var ingredient: Ingredient
    var isRemoving: Bool = false
    var isAdding: Bool = false
    let onRemove: () -> Void
    
    private var backgroundColor: Color {
        if isRemoving {
            return Color.red.opacity(0.2)
        } else if isAdding {
            return Color.green.opacity(0.2)
        } else {
            return Color.white
        }
    }
    
    private var borderColor: Color {
        if isRemoving {
            return Color.red
        } else if isAdding {
            return Color.green
        } else {
            return Color.black
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                Text("Name")
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 90, alignment: .leading)
                    .foregroundStyle(Color(hex: "#453736"))
                if isAdding {
                    Text(ingredient.name)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#453736"))
                } else {
                    TextField("name", text: $ingredient.name)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#453736"))
                }
            }
            
            HStack(spacing: 16) {
                Text("Quantity")
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 90, alignment: .leading)
                    .foregroundStyle(Color(hex: "#453736"))
                if isAdding {
                    Text(String(ingredient.quantity))
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#453736"))
                } else {
                    TextField("##", text: Binding(
                        get: { String(ingredient.quantity) },
                        set: { ingredient.quantity = Int($0) ?? 0 }
                    ))
                    .font(.system(size: 16))
                    .keyboardType(.numberPad)
                    .foregroundStyle(Color(hex: "#453736"))
                }
            }
            
            HStack(spacing: 16) {
                Text("Unit")
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 90, alignment: .leading)
                    .foregroundStyle(Color(hex: "#453736"))
                
                if isAdding {
                    Text(ingredient.unit)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#453736"))
                } else {
                    TextField("measurement", text: $ingredient.unit)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#453736"))
                }
            }
            
            HStack(spacing: 16) {
                Text("Preparation")
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 90, alignment: .leading)
                    .foregroundStyle(Color(hex: "#453736"))
                if isAdding {
                    Text(ingredient.preparation)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#453736"))
                } else {
                    TextField("how to prepare", text: $ingredient.preparation)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#453736"))
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
                .padding(.horizontal, -10)
        
            if !isAdding {
                Button(action: onRemove) {
                    Text("Remove")
                        .foregroundColor(Color(hex: "#FF3F49"))
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: isRemoving || isAdding ? 2 : 1)
        )
        .padding(.vertical, 4)
    }
}


//#Preview {
//    AddIngredients()
//}
