//
//  SearchView.swift
//  Yes Chef
//
//  Created by ananya on 10/23/25.
//

import SwiftUI

struct SearchView : View {
    @State private var viewModel = SearchViewModel()
    @State private var postVM = PostViewModel()
    @State private var showFilters = false
    @Environment(AuthenticationVM.self) var authVM

    @State private var searchText: String = ""
    @Binding var selectedIngredients: Set<String>
    @Binding var selectedAllergens: Set<String>
    @Binding var selectedDifficulty: Difficulty
    @Binding var selectedServingSize: Int
    @Binding var selectedTags: Set<String>
    @Binding var minPrepTime: Int?
    @Binding var maxPrepTime: Int?

    
    @Binding var hasAppliedFilters: Bool

    @Environment(\.dismiss) var dismiss

    init(
        searchText: String,
        selectedIngredients: Binding<Set<String>>,
        selectedAllergens: Binding<Set<String>>,
        selectedDifficulty: Binding<Difficulty>,
        selectedServingSize: Binding<Int>,
        selectedTags: Binding<Set<String>>,
        minPrepTime: Binding<Int?>,
        maxPrepTime: Binding<Int?>,
        hasAppliedFilters: Binding<Bool>
    ) {
        self.searchText = searchText
        self._selectedIngredients = selectedIngredients
        self._selectedAllergens = selectedAllergens
        self._selectedDifficulty = selectedDifficulty
        self._selectedServingSize = selectedServingSize
        self._selectedTags = selectedTags
        self._minPrepTime = minPrepTime
        self._maxPrepTime = maxPrepTime
        self._hasAppliedFilters = hasAppliedFilters
    }



    
    //let allItems = ["Pizza", "Pasta", "Salad", "Soup", "Sandwich", "Cake", "Curry"]

    var filteredItems: [Recipe] {
        postVM.recipes.filter { recipe in
            let matchesSearch = searchText.isEmpty ||
                recipe.name.localizedCaseInsensitiveContains(searchText)
            
            let matchesIngredients =
                selectedIngredients.isEmpty ||
                selectedIngredients.allSatisfy { ingredient in
                    recipe.ingredients.contains {
                        $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        == ingredient.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
            
            let matchesAllergens =
                selectedAllergens.isEmpty ||
                recipe.allergens.allSatisfy { allergen in
                    !selectedAllergens.contains(allergen)
                }
            
            let matchesTags =
                selectedTags.isEmpty ||
                selectedTags.allSatisfy { tag in
                    recipe.tags.contains { $0.lowercased() == tag.lowercased() }
                }
            
            let matchesDifficulty = selectedDifficulty == .none || recipe.difficulty == selectedDifficulty
            
            let matchesServingSize = selectedServingSize <= 1 || recipe.servingSize == selectedServingSize
            
            let matchesPrepTime = (
                (minPrepTime == nil || recipe.prepTime >= (minPrepTime ?? 0)) &&
                (maxPrepTime == nil || recipe.prepTime <= (maxPrepTime ?? Int.max))
            )
            
            return matchesSearch && matchesIngredients && matchesAllergens && matchesDifficulty && matchesServingSize && matchesTags && matchesPrepTime

        }
    }

    var body: some View {
        VStack {
            HStack {
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#FFA947"))
                }
                .padding(.leading, 15)
                
                Button ()  {
                    showFilters = true
                } label: {
                    if hasAppliedFilters{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#FFA947"))
                            .stroke(Color(hex: "#FFA947"), lineWidth: 1).overlay(
                                HStack {
                                    Image(systemName: "slider.horizontal.3").font(.system(size: 30))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                    .foregroundColor(Color(hex: "#F9F5F2"))
                                }
                            )
                        
                    } else {

                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#F9F5F2"))
                            .stroke(Color(hex: "#FFA947"), lineWidth: 1).overlay(
                                Image(systemName: "slider.horizontal.3").font(.system(size: 30))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                .foregroundColor(Color(hex: "#FFA947"))
                                )
                    }
                }
                .frame(width: 44, height: 43)
                .padding(.leading, 4)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "#FFA947"))
                    
                    TextField("", text: $searchText).foregroundColor(Color.black)
                    
                }
                .padding(10)
                .background(Color(hex: "#F9F5F2"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "FFA947"), lineWidth: 1)
                )
                .padding(.horizontal, 10)
                .padding(.trailing, 15)
            }
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            
            
            ScrollView {
                HStack(alignment: .top, spacing: 15) {
                    // Left column
                    LazyVStack(spacing: 15) {
                        ForEach(filteredItems.enumerated().filter { $0.offset % 2 == 0 }, id: \.element.id) { _, recipe in
                            NavigationLink(destination: PostView(recipe: recipe).environment(authVM)) {
                                RecipeItem(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Right column
                    LazyVStack(spacing: 15) {
                        ForEach(filteredItems.enumerated().filter { $0.offset % 2 == 1 }, id: \.element.id) { _, recipe in
                            NavigationLink(destination: PostView(recipe: recipe).environment(authVM)) {
                                RecipeItem(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                .padding(.horizontal, 15)
                .padding(.top, 15)

            }

        }
        .background(Color(hex: "#fffdf7"))
        .navigationBarBackButtonHidden(true)
        
        
        .task {
            await viewModel.getAllUsers()
            await viewModel.getAllUsernames()
            do {
                try await postVM.fetchPosts()
            } catch {
                print("fetch recipe error")
            }

        }
        .sheet(isPresented: $showFilters) {
            FilterView(
                show: $showFilters,
                onApply: { searchTextFromFilter, ingredients, allergens, difficulty, servingSize, tags, minTime, maxTime, isFiltered in
                    if !searchTextFromFilter.isEmpty {
                        self.searchText = searchTextFromFilter
                    }
                    self.selectedIngredients = ingredients
                    self.selectedAllergens = allergens
                    self.selectedDifficulty = difficulty
                    self.selectedServingSize = servingSize
                    self.selectedTags = tags
                    self.minPrepTime = minTime
                    self.maxPrepTime = maxTime
                    self.hasAppliedFilters = isFiltered
                    self.showFilters = false
                }
            )
        }
        .preferredColorScheme(.light)

    }
}
struct RecipeItem: View {
    let recipe: Recipe
    @Environment(AuthenticationVM.self) var authVM
    var body: some View {
        VStack {
            ZStack {
                if let media = recipe.media.first, !media.isEmpty {
                    AsyncImage(url: URL(string: media)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView() // Image is loading
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: (UIScreen.main.bounds.width - 45) / 2)
                        case .failure:
                            RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray6))
                                .overlay(Text(recipe.name))
                                .frame(height: 160)
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray6))
                        .overlay(Text(recipe.name))
                        .frame(height: 160)
                }
            }
            
            .frame(width: (UIScreen.main.bounds.width - 45) / 2)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            //Text(recipe.name).font(.caption)
        }
    }
    }

#Preview {
    SearchView(
        searchText: "s",
        selectedIngredients: .constant([]),
        selectedAllergens: .constant([]),
        selectedDifficulty: .constant(.easy),
        selectedServingSize: .constant(1),
        selectedTags: .constant([]),
        minPrepTime: .constant(0),
        maxPrepTime: .constant(1000),
        hasAppliedFilters: .constant(false)
    )
}
