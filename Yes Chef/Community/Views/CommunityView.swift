//
//  CommunityView.swift
//  Yes Chef
//
//  Created by Kushi Kashyap on 9/20/25.
//
import SwiftUI

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CommunityView : View {
    @State private var searchText = ""
    @State private var viewModel = SearchViewModel()
    @State private var postVM = PostViewModel()
    @State private var showFilters = false
    @State private var showSearch = false
    @State private var searchon = true
    @Environment(AuthenticationVM.self) var authVM
    @State private var hasAppliedFilters: Bool = false


    @State private var selectedIngredients: Set<String> = []
    @State private var selectedAllergens: Set<String> = []
    @State private var selectedTags: Set<String> = []
    @State private var selectedDifficulty: Difficulty = .none
    @State private var selectedServingSize: Int = 1
    @State private var minPrepTime: Int? = nil
    @State private var maxPrepTime: Int? = nil
    
    @StateObject private var leaderboardData = LeaderboardData()



    
//    @State private var selectedCuisine: Set<String> = []
//    @State private var selectedDietary: Set<String> = []
//    @State private var selectedDifficulty: Set<String> = []
//    @State private var selectedTime: Set<String> = []
//    @State private var selectedTags: Set<String> = []
    
    
    var weeklyChallengeRecipes: [Recipe] {
        let challengeIds = Set(leaderboardData.currentLeaderboard.entries.map { $0.id })
        return postVM.recipes.filter { challengeIds.contains($0.id ?? "") }
    }

    var filteredUsernames: [User] {
        guard !searchText.isEmpty else { return [] }
        return viewModel.users.filter { $0.username.localizedCaseInsensitiveContains(searchText) }
    }

    var filteredRecipes: [Recipe] {
        guard !searchText.isEmpty else { return [] }

        return postVM.recipes.filter { recipe in
            let matchesSearch = recipe.name.localizedCaseInsensitiveContains(searchText)
//            let matchesCuisine = selectedCuisine.isEmpty || !selectedCuisine.isDisjoint(with: Set(recipe.tags))
//            let matchesDietary = selectedDietary.isEmpty || !selectedDietary.isDisjoint(with: Set(recipe.tags))
//            let matchesDifficulty = selectedDifficulty.isEmpty || !selectedDifficulty.isDisjoint(with: Set(recipe.tags))
//            let matchesTime = selectedTime.isEmpty || !selectedTime.isDisjoint(with: Set(recipe.tags))
//            let matchesTags = selectedTags.isEmpty || !selectedTags.isDisjoint(with: Set(recipe.tags))

            return matchesSearch
            //&& matchesCuisine && matchesDietary && matchesDifficulty && matchesTime && matchesTags
        }
    }

    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#404741"))
                        .padding(.leading, 15)
                    
                    Text("Hi Chef!")
                        .font(.custom("Georgia", size: 32))
                        .foregroundColor(Color(hex: "#404741"))
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                HStack {
                    Button ()  {
                        showFilters = true
                    } label: {
//                        if !hasAppliedFilters {
//                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#F9F5F2"))
                                .stroke(Color(hex: "#FFA947"), lineWidth: 1).overlay(
                                    Image(systemName: "slider.horizontal.3").font(.system(size: 30))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                    .foregroundColor(Color(hex: "#FFA947"))
                                    )
//                        } else {
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(.orange)
//                                .stroke(Color.orange, lineWidth: 1).overlay(
//                                    Image(systemName: "slider.horizontal.2.square").font(.system(size: 30))
//                                        .padding(.horizontal, 10)
//                                        .padding(.vertical, 10)
//                                        .foregroundColor(Color(hex: "#fffdf7"))
//                                )
                        //}
                    }
                    .frame(width: 44, height: 43)
                    .padding(.leading, 15)
                    
                    ZStack {
                        TextField("Search...", text: $searchText)
                            .onSubmit {
                                showSearch = false
                                        DispatchQueue.main.async {
                                            showSearch = true
                                        }
                            }
                            .padding(10)
                            .padding(.trailing, 30) // extra space for the icon
                            .background(Color(hex: "#F9F5F2"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "#FFA947"), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        


                        
                        NavigationLink(destination: SearchView(
                            searchText: searchText,
                            selectedIngredients: $selectedIngredients,
                            selectedAllergens: $selectedAllergens,
                            selectedDifficulty: $selectedDifficulty,
                            selectedServingSize: $selectedServingSize,
                            selectedTags: $selectedTags,
                            minPrepTime: $minPrepTime,
                            maxPrepTime: $maxPrepTime,
                            hasAppliedFilters: $hasAppliedFilters
                        )
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
                    VStack(alignment: .leading, spacing: 0) {
                        Divider()
                            .padding(.vertical, 6)

                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(Array(filteredUsernames.enumerated()), id: \.offset) { _, user in
                                    NavigationLink(destination: ProfileView(user: user).environment(authVM)) {
                                        HStack {
                                            Text(user.username)
                                                .foregroundColor(.primary)
                                                .padding(.vertical, 10)
                                            Spacer()
                                            Image(systemName: "arrow.up.right")
                                                .foregroundColor(Color(hex: "#F9F5F2"))
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    Divider()
                                        .padding(.leading, 16)
                                }

                                ForEach(filteredRecipes) { recipe in
                                    NavigationLink(destination: PostView(recipe: recipe).environment(authVM)) {
                                        HStack {
                                            Text(recipe.name)
                                                .foregroundColor(.primary)
                                                .padding(.vertical, 10)
                                            Spacer()
                                            Image(systemName: "arrow.up.right")
                                                .foregroundColor(Color(hex: "#F9F5F2"))
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 1)
                    .padding(.horizontal)
                    .zIndex(1)
                } else {
                    if postVM.recipes.isEmpty {
                        Text("Loading...")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 25) {
                                RecipeSection(title: "This Week's Challenges!", items: weeklyChallengeRecipes, wide: true)
                                    .environment(authVM)
                           }
                            if !postVM.recipes.isEmpty {
                                let trending = Array(postVM.recipes.prefix(10))
                                RecipeSection(title: "Trending", items: trending, wide: false)
                                    .environment(authVM)
                                    .padding(.top, 20)
                            }

                            }
                                
                            .padding(.bottom, 20)
                        
                        }
                    }
                }
                Spacer()
            }
            .background(Color(hex: "#fffdf7"))
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
            }
            .task {
                await viewModel.getAllUsers()
                await viewModel.getAllUsernames()
                do {
                    try await postVM.fetchPosts()
                } catch {
                    print("Failed to fetch recipes: \(error)")
                }
                leaderboardData.fetchUserRecipes()
            }
            .onAppear {
                selectedIngredients = []
                selectedAllergens = []
                selectedTags = []
                selectedDifficulty = .none
                selectedServingSize = 1
                minPrepTime = nil
                maxPrepTime = nil
                hasAppliedFilters = false
                searchText = ""
            }
        .sheet(isPresented: $showFilters) {
            FilterView(
                show: $showFilters,
                onApply: { searchText, ingredients, allergens, difficulty, servingSize, tags, minTime, maxTime, isFiltered in
                    self.searchText = searchText
                    self.selectedIngredients = ingredients
                    self.selectedAllergens = allergens
                    self.selectedDifficulty = difficulty
                    self.selectedServingSize = servingSize
                    self.selectedTags = tags
                    self.minPrepTime = minTime
                    self.maxPrepTime = maxTime
                    self.hasAppliedFilters = isFiltered

                    
                    DispatchQueue.main.async {
                        showSearch = true
                    }
                }
            )
        }

            .preferredColorScheme(.light)
        }
    }


struct RecipeSection: View {
    @Environment(AuthenticationVM.self) var authVM
    let title: String
    let items: [Recipe]
    let wide: Bool
    //@Environment(AuthenticationVM.self) var authVM
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.custom("Georgia", size: 24))
                .foregroundColor(Color(hex: "#404741"))
                .fontWeight(.bold)
                .padding(.horizontal, 20)
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    if (wide) {
                        ForEach(items) { recipe in
                            NavigationLink(destination: PostView(recipe: recipe).environment(authVM)) {
                                RecipeCard(recipe: recipe, wide: wide)
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        ForEach(items) { recipe in
                            NavigationLink(destination: PostView(recipe: recipe).environment(authVM)) {
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
