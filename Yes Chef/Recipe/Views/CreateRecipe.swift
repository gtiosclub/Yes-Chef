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
                    SectionHeader(title: "Recipe Name")

                    StyledTextField(placeholder: "Enter Recipe Name", text: $recipeVM.name)
                    
                    SectionHeader(title: "Recipe Description")

                    StyledTextField(placeholder: "Enter Recipe Description", text: $recipeVM.description, height: 60)
                    
                    SectionHeader(title: "Add Media")
                    
                    AddMedia(mediaItems: $recipeVM.mediaItems)
                        .padding(.leading, 15)
                    
                    SectionHeader(title: "Ingredients")
                                        
                    AddIngredients(ingredients: $recipeVM.ingredients)
                    
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

                    StyledTextField(placeholder: "Enter Prep Time in Minutes", text: $recipeVM.prepTimeInput, keyboardType: .numberPad)
                    
                    HStack {
                        SectionHeader(title: "Difficulty")
                        Spacer(minLength: 40)
                        SectionHeader(title: "Serving Size")
                    }
                    
                    HStack {
                        DifficultyLevelView(difficulty: $recipeVM.difficulty)
                        Spacer(minLength: 50)
                        ServingSizeView(selectedServingSize: $recipeVM.servingSize)
                    }
                    .padding(.horizontal)
                    
                    SectionHeader(title: "Chef's Notes")
                    
                    StyledTextField(placeholder: "What else would you like your chef to know?", text: $recipeVM.chefsNotes, height: 40)
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
            .padding(.bottom, -0.5)
    }
}

#Preview {
    CreateRecipe(recipeVM: CreateRecipeVM())
}
