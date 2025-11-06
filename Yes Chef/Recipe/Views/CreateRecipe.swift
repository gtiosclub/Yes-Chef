//
//  RecipeView.swift
//  Yes Chef
//
//  Created by RushilC on 9/20/25.
//

import SwiftUI
import AVKit

struct CreateRecipe: View {
    @State var recipeVM: CreateRecipeVM
    @State private var selectedMediaIndex: Int? = nil
    @State private var isEditingMedia: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 7) {
                        SectionHeader(title: "Recipe Name")
                        
                        StyledTextField(placeholder: "What is your dish called?", text: $recipeVM.name)
                        
                        SectionHeader(title: "Recipe Description")
                        
                        StyledTextField(placeholder: "Describe your recipe in a few words...", text: $recipeVM.description, height: 40)
                        
                        SectionHeader(title: "Add Media")
                        AddMedia(mediaItems: $recipeVM.mediaItems) { index in
                            selectedMediaIndex = index
                            isEditingMedia = true
                        }
                        .padding(.leading, 15)
                        
                        SectionHeader(title: "Prep & Cook Time")
                        
                        StyledTextField(placeholder: "How many minutes will it take to cook this?", text: $recipeVM.prepTimeInput, keyboardType: .numberPad)
                        
                        SectionHeader(title: "Difficulty")
                        DifficultyLevelView(difficulty: $recipeVM.difficulty)
                            .padding(.horizontal, 10)
                        
                        SectionHeader(title: "Serving Size")
                        ServingSizeView(selectedServingSize: $recipeVM.servingSize)
                        
                        SectionHeader(title: "Ingredients")
                        
                        AddIngredients(ingredients: $recipeVM.ingredients)
                        
                        StepsInputView(steps: $recipeVM.steps)
                        
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
                        
                        SectionHeader(title: "Chef's Notes")
                        
                        StyledTextField(placeholder: "What else would you like your chef to know?", text: $recipeVM.chefsNotes, height: 40)
                    }
                    NavigationLink(
                        destination: Group {
                            if let index = selectedMediaIndex {
                                EditMedia(
                                    image: recipeVM.mediaItems[index].mediaType == .photo
                                    ? UIImage(contentsOfFile: recipeVM.mediaItems[index].localPath.path)
                                    : nil,
                                    videoURL: recipeVM.mediaItems[index].mediaType == .video
                                    ? recipeVM.mediaItems[index].localPath
                                    : nil
                                )
                            } else {
                                EmptyView()
                            }
                        },
                        isActive: $isEditingMedia
                    ) {
                        EmptyView()
                    }
                    .hidden()
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
