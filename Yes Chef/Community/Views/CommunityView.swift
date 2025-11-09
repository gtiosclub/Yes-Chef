//
//  CommunityView.swift
//  Yes Chef
//
//  Created by Kushi Kashyap on 9/20/25.
//
import SwiftUI

struct CommunityView : View {
    @State private var searchText = ""
    @State private var viewModel = SearchViewModel()
    @State private var postVM = PostViewModel()
    @State private var showFilters = false
    @State private var showSearch = false
    @State private var searchon = true
    @Environment(AuthenticationVM.self) var authVM

    
    @State private var selectedCuisine: Set<String> = []
    @State private var selectedDietary: Set<String> = []
    @State private var selectedDifficulty: Set<String> = []
    @State private var selectedTime: Set<String> = []
    @State private var selectedTags: Set<String> = []
    
    

    var filteredUsernames: [User] {
        guard !searchText.isEmpty else { return [] }
        return viewModel.users.filter { $0.username.localizedCaseInsensitiveContains(searchText) }
    }

    var filteredRecipes: [Recipe] {
        guard !searchText.isEmpty else { return [] }

        return postVM.recipes.filter { recipe in
            let matchesSearch = recipe.name.localizedCaseInsensitiveContains(searchText)
            let matchesCuisine = selectedCuisine.isEmpty || !selectedCuisine.isDisjoint(with: Set(recipe.tags))
            let matchesDietary = selectedDietary.isEmpty || !selectedDietary.isDisjoint(with: Set(recipe.tags))
            let matchesDifficulty = selectedDifficulty.isEmpty || !selectedDifficulty.isDisjoint(with: Set(recipe.tags))
            let matchesTime = selectedTime.isEmpty || !selectedTime.isDisjoint(with: Set(recipe.tags))
            let matchesTags = selectedTags.isEmpty || !selectedTags.isDisjoint(with: Set(recipe.tags))

            return matchesSearch && matchesCuisine && matchesDietary && matchesDifficulty && matchesTime && matchesTags
        }
    }

    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                        .padding(.leading, 15)
                    
                    Text("Hi Chef!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                HStack {
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
                                    Image(systemName: "slider.horizontal.2.square").font(.system(size: 30))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                    .foregroundColor(.white)
                                    
                                )
                        }
                    }
                    .frame(width: 44, height: 43)
                    .padding(.leading, 15)
                    
                    ZStack {
                        TextField("Search...", text: $searchText)
                            .onSubmit {
                                showSearch = true
                             }
                            .padding(10)
                            .padding(.trailing, 30) // extra space for the icon
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                            .padding(.horizontal)
                        


                        
                        NavigationLink(destination: SearchView(text: searchText, selectedCuisine: $selectedCuisine,
                            selectedDietary:
                            $selectedDietary, selectedDifficulty: $selectedDifficulty, selectedTime: $selectedTime, selectedTags: $selectedTags)
                                .environment(authVM),
                                isActive: $showSearch) {
                                EmptyView()
                                }
                       
                        
                        HStack {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.orange)
                                .padding(.trailing, 30) // match the extra padding in TextField
                        }
                    }
                }
                .padding(.bottom, 10)
                
                if !filteredUsernames.isEmpty || !filteredRecipes.isEmpty {
                    List {
                        ForEach(filteredUsernames) { user in
                            NavigationLink(destination: ProfileView(user: user).environment(authVM)) {
                                Text(user.username)
                            }
                        }

                        ForEach(filteredRecipes) { recipe in
                            NavigationLink(destination: PostView(recipe: recipe).environment(authVM)) {
                                HStack {
                                    Text(recipe.name)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)

                    .listStyle(.plain)
                    .frame(maxHeight: 200)
                    Spacer()
                } else {
                    if postVM.recipes.isEmpty {
                        Text("Loading...")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 25) {
                                RecipeSection(title: "This Week's Challenges!", items: Array(postVM.recipes[0..<5]),wide: true)
                           }
                            if !postVM.recipes.isEmpty {
                                let trending = Array(postVM.recipes.prefix(10))
                                RecipeSection(title: "Trending", items: trending, wide: false)
                            }

                            }
        
                                
                            .padding(.bottom, 20)
                        }
                    }
                }
                Spacer()
            }
            .background(Color(hex: "#fffdf7"))
            .task {
                await viewModel.getAllUsers()
                await viewModel.getAllUsernames()
                do {
                    try await postVM.fetchPosts()
                } catch {
                    print("Failed to fetch recipes: \(error)")
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


struct RecipeSection: View {
    let title: String
    let items: [Recipe]
    let wide: Bool
    //@Environment(AuthenticationVM.self) var authVM
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    if (wide) {
                        ForEach(items) { recipe in
                            NavigationLink(destination: PostView(recipe: recipe)) {
                                RecipeCard(recipe: recipe, wide: wide)
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        ForEach(items) { recipe in
                            NavigationLink(destination: PostView(recipe: recipe)) {
                                RecipeCard(recipe: recipe, wide: false)
                            }
                        }
                    }

                    
                }
                .padding(.horizontal, 20)
            }
        }
    }
}


struct RecipeCard: View {
    let recipe: Recipe
    let wide: Bool
    //@Environment(AuthenticationVM.self) var authVM
    var body: some View {
        if wide {
            ZStack {
                if let media = recipe.media.first, !media.isEmpty {
                    AsyncImage(url: URL(string: media)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color(.systemGray6)
                            .overlay(Text(recipe.name))
                    }
                } else {
                    Color(.systemGray6)
                        .overlay(Text(recipe.name))
                }
            }
            .frame(width: 350, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            ZStack {
                if let media = recipe.media.first, !media.isEmpty {
                    AsyncImage(url: URL(string: media)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color(.systemGray6)
                            .overlay(Text(recipe.name))
                    }
                } else {
                    Color(.systemGray6)
                        .overlay(Text(recipe.name))
                }
            }
            .frame(width: 160, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
#Preview {
    CommunityView()
        .environment(AuthenticationVM())
}
