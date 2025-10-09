//  RecipeView.swift
//  Yes Chef
//
//  Created by RushilC on 9/20/25.
//

import SwiftUI

struct CreateRecipe: View {
    @State private var userIdInput = ""
    @State private var name = ""
    @State private var description = ""
    @State private var ingredientsInput = ""
    @State private var allergensInput = ""
    @State private var tagsInput = ""
    @State private var prepTimeInput = ""
    @State private var difficulty: Difficulty = .easy
    @State private var recipeVM = RecipeVM()
    @State private var statusMessage = ""
    @State private var steps: [String] = [""]
    @State private var mediaInputs: [String] = [""]

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
                        .padding(.bottom, -23)
                    
                    SearchableDropdownView(
                        viewModel: SearchableDropdownVM(options: Ingredient.allIngredients)
                    )
                    
                    Text("Allergens")
                        .font(.title)
                        .padding()
                        .padding(.bottom, -23)
                    
                    SearchableDropdownView(
                        viewModel: SearchableDropdownVM(options: Allergen.allCases)
                    )
                    
                    Text("Tags")
                        .font(.title)
                        .padding()
                        .padding(.bottom, -23)
                    
                    SearchableDropdownView(
                        viewModel: SearchableDropdownVM(options: Tag.allTags)
                    )
                    
                    StepsInputView(steps: $steps)
                    //NewRecipeView(steps: $steps)
                    
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
                        ForEach(Difficulty.allCases, id: \.self) { level in
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
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.red)
                            .bold()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            let ingredients = ingredientsInput
                                .split(separator: ",")
                                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                            let allergens = allergensInput
                                .split(separator: ",")
                                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                            let tags = tagsInput
                                .split(separator: ",")
                                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                            let prepTime = Int(prepTimeInput) ?? 0
                            
                            await recipeVM.createRecipe(
                                userId: userIdInput,
                                name: name,
                                ingredients: ingredients,
                                allergens: allergens,
                                tags: tags,
                                steps: steps,
                                description: description,
                                prepTime: prepTime,
                                difficulty: difficulty,
                                media: mediaInputs
                            )
                        }
                    } label: {
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
    CreateRecipe()
}
