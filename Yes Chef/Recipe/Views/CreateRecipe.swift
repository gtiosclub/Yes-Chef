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
    
    // Extract preview data from toolcalls
    private var namePreview: (removing: [String], adding: [String]) {
        extractPreviewData(for: "name", or: "title")
    }
    
    private var descriptionPreview: (removing: [String], adding: [String]) {
        extractPreviewData(for: "description")
    }
    
    private var prepTimePreview: (removing: [String], adding: [String]) {
        extractPreviewData(for: "preptime", or: "prep time")
    }
    
    private var chefsNotesPreview: (removing: [String], adding: [String]) {
        extractPreviewData(for: "chefsnotes", or: "chef's notes")
    }
    
    private var ingredientsPreview: (removing: [String], adding: [Ingredient]) {
        guard let toolcalls = recipeVM.toolcall else {
            return (removing: [], adding: [])
        }
        
        var removing: [String] = []
        var adding: [Ingredient] = []
        
        for toolcall in toolcalls {
            let item = toolcall.item.lowercased()
            if item == "ingredients" {
                removing.append(contentsOf: toolcall.removing)
                for addingItem in toolcall.adding {
                    switch addingItem {
                    case .ingredient(let ingredient):
                        adding.append(ingredient)
                    case .string(let ingredientString):
                        // Create an Ingredient from the string (matching applyChanges behavior)
                        adding.append(Ingredient(name: ingredientString.trimmingCharacters(in: .whitespacesAndNewlines)))
                    }
                }
            }
        }
        
        return (removing: removing, adding: adding)
    }
    
    private var stepsPreview: (removing: [String], adding: [String]) {
        guard let toolcalls = recipeVM.toolcall else {
            return (removing: [], adding: [])
        }
        
        var removing: [String] = []
        var adding: [String] = []
        
        for toolcall in toolcalls {
            let item = toolcall.item.lowercased()
            if item == "steps" {
                removing.append(contentsOf: toolcall.removing)
                for addingItem in toolcall.adding {
                    if case .string(let step) = addingItem {
                        adding.append(step)
                    }
                }
            }
        }
        
        return (removing: removing, adding: adding)
    }
    
    private var allergensPreview: (removing: [String], adding: [String]) {
        guard let toolcalls = recipeVM.toolcall else {
            return (removing: [], adding: [])
        }
        
        var removing: [String] = []
        var adding: [String] = []
        
        for toolcall in toolcalls {
            let item = toolcall.item.lowercased()
            if item == "allergens" {
                removing.append(contentsOf: toolcall.removing)
                for addingItem in toolcall.adding {
                    if case .string(let allergen) = addingItem {
                        adding.append(allergen)
                    }
                }
            }
        }
        
        return (removing: removing, adding: adding)
    }
    
    private var tagsPreview: (removing: [String], adding: [String]) {
        guard let toolcalls = recipeVM.toolcall else {
            return (removing: [], adding: [])
        }
        
        var removing: [String] = []
        var adding: [String] = []
        
        for toolcall in toolcalls {
            let item = toolcall.item.lowercased()
            if item == "tags" {
                removing.append(contentsOf: toolcall.removing)
                for addingItem in toolcall.adding {
                    if case .string(let tag) = addingItem {
                        adding.append(tag)
                    }
                }
            }
        }
        
        return (removing: removing, adding: adding)
    }
    
    private func extractPreviewData(for item: String, or alternative: String? = nil) -> (removing: [String], adding: [String]) {
        guard let toolcalls = recipeVM.toolcall else {
            return (removing: [], adding: [])
        }
        
        var removing: [String] = []
        var adding: [String] = []
        
        for toolcall in toolcalls {
            let toolcallItem = toolcall.item.lowercased()
            if toolcallItem == item || (alternative != nil && toolcallItem == alternative?.lowercased()) {
                removing.append(contentsOf: toolcall.removing)
                for addingItem in toolcall.adding {
                    if case .string(let value) = addingItem {
                        adding.append(value)
                    }
                }
            }
        }
        
        return (removing: removing, adding: adding)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 7) {
                        SectionHeader(title: "Recipe Name")
                        
                        StyledTextField(
                            placeholder: "What is your dish called?",
                            text: $recipeVM.name,
                            previewRemoving: namePreview.removing,
                            previewAdding: namePreview.adding
                        )
                        
                        SectionHeader(title: "Recipe Description")
                        
                        StyledTextField(
                            placeholder: "Describe your recipe in a few words...",
                            text: $recipeVM.description,
                            height: 40,
                            previewRemoving: descriptionPreview.removing,
                            previewAdding: descriptionPreview.adding
                        )
                        
                        SectionHeader(title: "Add Media")
                        AddMedia(mediaItems: $recipeVM.mediaItems) { index in
                            selectedMediaIndex = index
                            isEditingMedia = true
                        }
                        .padding(.leading, 15)
                        
                        SectionHeader(title: "Prep & Cook Time")
                        
                        StyledTextField(
                            placeholder: "How many minutes will it take to cook this?",
                            text: $recipeVM.prepTimeInput,
                            keyboardType: .numberPad,
                            previewRemoving: prepTimePreview.removing,
                            previewAdding: prepTimePreview.adding
                        )
                        
                        SectionHeader(title: "Difficulty")
                        DifficultyLevelView(difficulty: $recipeVM.difficulty)
                            .padding(.horizontal, 10)
                        
                        SectionHeader(title: "Serving Size")
                        ServingSizeView(selectedServingSize: $recipeVM.servingSize)
                        
                        SectionHeader(title: "Ingredients")
                        
                        AddIngredients(
                            ingredients: $recipeVM.ingredients,
                            previewRemoving: ingredientsPreview.removing,
                            previewAdding: ingredientsPreview.adding
                        )
                        
                        StepsInputView(
                            steps: $recipeVM.steps,
                            previewRemoving: stepsPreview.removing,
                            previewAdding: stepsPreview.adding
                        )
                        
                        SectionHeader(title: "Allergens")
                        
                        SearchableDropdown(
                            options: Allergen.allCases,
                            selectedValues: $recipeVM.selectedAllergens,
                            placeholder: "Add allergens...",
                            allowCustom: true,
                            previewRemoving: allergensPreview.removing,
                            previewAdding: allergensPreview.adding
                        )
                        
                        SectionHeader(title: "Tags")
                        
                        SearchableDropdown(
                            options: Tag.allTags,
                            selectedValues: $recipeVM.selectedTags,
                            placeholder: "Add tags...",
                            allowCustom: false,
                            previewRemoving: tagsPreview.removing,
                            previewAdding: tagsPreview.adding
                        )
                        
                        SectionHeader(title: "Chef's Notes")
                        
                        StyledTextField(
                            placeholder: "What else would you like your chef to know?",
                            text: $recipeVM.chefsNotes,
                            height: 40,
                            previewRemoving: chefsNotesPreview.removing,
                            previewAdding: chefsNotesPreview.adding
                        )
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
