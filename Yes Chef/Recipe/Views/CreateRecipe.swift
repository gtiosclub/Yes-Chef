//  RecipeView.swift
//  Yes Chef
//
//  Created by RushilC on 9/20/25.
//

import SwiftUI

struct CreateRecipe: View {
    @State var recipeVM: CreateRecipeVM

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    SectionHeader(title: "Name")

                    TextField("Enter Recipe Name", text: $recipeVM.name)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                    
                    SectionHeader(title: "Description")

                    TextField("Enter Recipe Description", text: $recipeVM.description)
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
                        selectedValues: $recipeVM.selectedIngredients,
                        placeholder: "Add ingredients...",
                        allowCustom: true
                    )
                    
                    SectionHeader(title: "Allergens")
                    
                    SearchableDropdown(
                        options: Allergen.allCases,
                        selectedValues: $recipeVM.selectedAllergens,
                        placeholder: "Add allergens...",
                        allowCustom: true
                    )
                
                    SectionHeader(title: "Tags")
                    
                    SearchableDropdown(
                        options: Tag.allTags,
                        selectedValues: $recipeVM.selectedTags,
                        placeholder: "Add tags...",
                        allowCustom: false
                    )
                    

                    StepsInputView(steps: $recipeVM.steps)
                    
                    SectionHeader(title: "Prep Time")

                    TextField("Enter Prep Time in Minutes", text: $recipeVM.prepTimeInput)
                        .keyboardType(.numberPad)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .foregroundColor(.secondary)

                    SectionHeader(title: "Media")
                    
                    AddMedia(selectedImages: $recipeVM.selectedImages, localMediaPaths: $recipeVM.localMediaPaths)
                        .padding(.horizontal)

                    

                    SectionHeader(title: "Difficulty")

                    DifficultyLevelView(difficulty: $recipeVM.difficulty)
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom("Georgia", size: 24))
            .foregroundStyle(Color(hex: "#453736"))
            .fontWeight(.semibold)
            .padding(.horizontal)
            .padding(.top, 4)
            .padding(.bottom, -2)
    }
}

//#Preview {
//    CreateRecipe(recipeVM: recipeVM)
//}
