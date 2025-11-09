//
//  SearchView.swift
//  Yes Chef
//
//  Created by ananya on 10/23/25.
//

import SwiftUI

struct SearchView : View {
    @State private var searchText = ""
    @State private var viewModel = SearchViewModel()
    @State private var postVM = PostViewModel()
    @State private var showFilters = false
    @Environment(AuthenticationVM.self) var authVM


    
    @Binding var selectedCuisine: Set<String>
    @Binding var selectedDietary: Set<String>
    @Binding var selectedDifficulty: Set<String>
    @Binding var selectedTime: Set<String>
    @Binding var selectedTags: Set<String>
    
    let text: String
    @Environment(\.dismiss) var dismiss
    init(searchText: String = "", viewModel: SearchViewModel = SearchViewModel(), text: String, selectedCuisine: Binding<Set<String>>,
         selectedDietary: Binding<Set<String>>,
         selectedDifficulty: Binding<Set<String>>,
         selectedTime: Binding<Set<String>>,
         selectedTags: Binding<Set<String>>) {
        self.searchText = text
        self.viewModel = viewModel
        self.text = text
        _selectedCuisine = selectedCuisine
        _selectedDietary = selectedDietary
        _selectedDifficulty = selectedDifficulty
        _selectedTime = selectedTime
        _selectedTags = selectedTags
    }
    
    //let allItems = ["Pizza", "Pasta", "Salad", "Soup", "Sandwich", "Cake", "Curry"]

    var filteredItems: [Recipe] {
        if searchText.isEmpty {
            return []
        } else {
            let allSearchableItems = postVM.recipes
            return allSearchableItems.filter {recipe in
                let matchesSearch = recipe.name.localizedCaseInsensitiveContains(searchText)
                let matchesCuisine = selectedCuisine.isEmpty || recipe.tags.contains { element in
                   selectedCuisine.contains(element)
                }
                let matchesDietary = selectedDietary.isEmpty || recipe.tags.contains { element in
                    selectedDietary.contains(element)
                }
                let matchesDifficulty = selectedDifficulty.isEmpty || recipe.tags.contains { element in
                    selectedDifficulty.contains(element)
                }
                let matchesTime = selectedTime.isEmpty || recipe.tags.contains { element in
                    selectedTime.contains(element)
                }
                let matchesTags = selectedTags.isEmpty || recipe.tags.contains { element in
                    selectedTags.contains(element)
                }
                return matchesSearch && matchesCuisine && matchesDietary && matchesDifficulty && matchesTime && matchesTags
                
            }
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
                        .foregroundColor(.orange)
                }
                .padding(.leading, 15)
                
                Button ()  {
                    showFilters = true
                } label: {
                    if(selectedCuisine.isEmpty && selectedDietary.isEmpty && selectedDifficulty.isEmpty && selectedTime.isEmpty && selectedTags.isEmpty) {
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                            .stroke(Color.orange, lineWidth: 1).overlay(
                                Image(systemName: "slider.horizontal.2.square").font(.system(size: 30))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                            
                                .foregroundColor(.orange)
                            )
                        
                        
                        
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.orange)
                            .stroke(Color.orange, lineWidth: 1).overlay(
                                HStack {
                                    Image(systemName: "slider.horizontal.2.square").font(.system(size: 30))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                    .foregroundColor(.white)
                                }
                            )
                    }
                }
                .frame(width: 44, height: 43)
                .padding(.leading, 4)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.orange)
                    
                    TextField("", text: $searchText).foregroundColor(Color.black)
                    
                }
                .padding(10)
                .background(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.orange, lineWidth: 1)
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
                        ForEach(Array(filteredItems.enumerated().filter { $0.offset % 2 == 0 }), id: \.element.id) { _, recipe in
                            NavigationLink(destination: PostView(recipe: recipe).environment(authVM)) {
                                RecipeItem(recipe: recipe)
                            }
                            .buttonStyle(.plain) // removes default nav link style
                        }
                    }

                    // Right column
                    LazyVStack(spacing: 15) {
                        ForEach(Array(filteredItems.enumerated().filter { $0.offset % 2 == 1 }), id: \.element.id) { _, recipe in
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
            FilterView(show: $showFilters,
               selectedCuisine: $selectedCuisine,
               selectedDietary: $selectedDietary,
               selectedDifficulty: $selectedDifficulty,
               selectedTime: $selectedTime,
               selectedTags: $selectedTags)
               
        }
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
    SearchView(text: "s",
               selectedCuisine:.constant([]),
               selectedDietary:.constant([]),
               selectedDifficulty:.constant([]),
               selectedTime:.constant([]),
               selectedTags:.constant([])
    )
    
}
