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
    @State private var selectedIngredients: [SearchableValue<Ingredient>] = []
    @State private var selectedAllergens: [SearchableValue<Allergen>] = []
    @State private var selectedTags: [SearchableValue<Tag>] = []
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
                    SectionHeader(title: "Name")
                
                    TextField("Enter Recipe Name", text: $name)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                    
                    SectionHeader(title: "Description")
                    
                    TextField("Enter Recipe Description", text: $description)
                        .font(.subheadline)
                        .padding(10)
                        .padding(.bottom,90)
                        .foregroundColor(.primary)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                    
                    SectionHeader(title: "Ingredients")
                                        
                    SearchableDropdown(
                        options: Ingredient.allIngredients,
                        selectedValues: $selectedIngredients,
                        placeholder: "Add ingredients...",
                        allowCustom: true
                    )
                    
                    // Allergens
                    SectionHeader(title: "Allergens")
                    
                    SearchableDropdown(
                        options: Allergen.allCases,
                        selectedValues: $selectedAllergens,
                        placeholder: "Add allergens...",
                        allowCustom: true
                    )
                    
                    // Tags
                    SectionHeader(title: "Tags")
                    
                    SearchableDropdown(
                        options: Tag.allTags,
                        selectedValues: $selectedTags,
                        placeholder: "Add tags...",
                        allowCustom: true
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
                        .background(Color(.systemGray6))
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
                            let ingredients = selectedIngredients.map { $0.displayName }
                            let allergens = selectedAllergens.map { $0.displayName }
                            let tags = selectedTags.map { $0.displayName }
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

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.horizontal)
            .padding(.top, 4)
    }
}

#Preview {
    CreateRecipe()
}
