//
//  RecipeView.swift
//  Yes Chef
//
//  Created by RushilC on 9/20/25.
//

import SwiftUI

struct RecipeView: View {
    @State private var name = ""
    @State private var description = ""
    @State private var ingredientsInput = ""
    @State private var allergensInput = ""
    @State private var tagsInput = ""
    @State private var prepTimeInput = ""
    @State private var difficulty: Difficulty = .easy
    @State private var recipeVM = RecipeVM()
    @State private var statusMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.title)
                        .padding()
                        .padding(.bottom, -40)
                    
                    TextField("Enter Recipe Name", text: $name)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)
                    
                    Text("Description")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)
                    
                    TextField("Enter Recipe Description", text: $description)
                        .font(.subheadline)
                        .padding(10)
                        .padding(.bottom,90)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)
                    
                    Text("Ingredients")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)
                    
                    TextField("Enter Ingredients (Comma Seperated)", text: $ingredientsInput)
                        .font(.subheadline)
                        .padding(10)
                        .padding(.bottom,30)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)
                    
                    Text("Allergens")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)
                    
                    TextField("Enter Allergens (Comma Seperated)", text: $allergensInput)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)
                    
                    Text("Tags")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)
                    
                    TextField("Enter Tags (Comma Seperated)", text: $tagsInput)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)
                    
                    Text("Steps")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                    
                    Text("Prep Time")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)
                    
                    TextField("Enter Prep Time in Minutes", text: $prepTimeInput)
                        .keyboardType(.numberPad)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)
                    
                    Text("Media")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                    
                    Text("Difficulty")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom,-20)
                    
                    Picker("Choose a Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .padding(.horizontal)
                }
            }
            

                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            // delete
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundStyle(.gray)
                                .bold()
                        }
                    }
                    
                    ToolbarItem(placement: .principal) { // This centers the title
                        Text("Add Recipe")
                            .font(.largeTitle)
                            
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            let ingredients = ingredientsInput
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

                            let allergens = allergensInput
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

                            let tags = tagsInput
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

                            let prepTime = Int(prepTimeInput) ?? 0

                    }) {
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .foregroundStyle(.gray)
                                .bold()
                        }
                    }
                }
        }
    }
}

#Preview {
    RecipeView()
}
