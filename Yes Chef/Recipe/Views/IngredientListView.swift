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
        NavigationView {
            ZStack {
                // 🔹 List background (light brown)
                Color(red: 245/255, green: 222/255, blue: 179/255)
                    .ignoresSafeArea()
                
                List {
                    ForEach(Array(ingredients.enumerated()), id: \.element.id) { i, ingredient in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Name:")
                                TextField("Name", text: $ingredients[i].name)
                                    .padding(6)
                                    .background(Color.white)
                                    .cornerRadius(4)
                            }
                            Stepper("Quantity: \(ingredients[i].quantity)", value: $ingredients[i].quantity, in: 0...100)
                            HStack {
                                Text("Unit:")
                                TextField("Unit", text: $ingredients[i].unit)
                                    .padding(6)
                                    .background(Color.white)
                                    .cornerRadius(4)
                            }
                            HStack {
                                Text("Preparation:")
                                TextField("Preparation", text: $ingredients[i].preparation)
                                    .padding(6)
                                    .background(Color.white)
                                    .cornerRadius(4)
                            }
                            
                            Divider()
                                .frame(height: 2)
                                .background(Color.gray)
                                .padding(.vertical, 2)
                            
                            Button {
                                ingredients.remove(at: i)
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Remove")
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 2)
                        }
                        .padding()
                        // 🔹 White background for entire card
                        .background(Color.white)
                        .cornerRadius(10)
                        // Optional gray border
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                        )
                        .listRowBackground(Color.clear) // keeps list background visible
                        .padding(.vertical, 4)
                    }
                    
                    // Add button at bottom
                    HStack {
                        Spacer()
                        Button {
                            ingredients.append(IngredientClass())
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                                .frame(width: 60, height: 60)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Ingredients")
        }
    }
}


#Preview {
    IngredientListView()
}
