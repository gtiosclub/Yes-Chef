//
//  Home.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/11/25.
//

import SwiftUI

struct Home: View {
    @State private var selectedView: TabSelection = .home
    @State var authViewModel = AuthenticationVM()
    let sampleRecipe = Recipe(
        userId: "zvUtxNaS4FRTC1522AsZLxCXl5s1",
        recipeId: "recipeID",
        name: "Chaffle",
        ingredients: ["1 egg", "3 cups of flour", "1 teaspoon butter"],
        allergens: [""],
        tags: ["american", "keto", "gluten free"],
        steps: [
            "Preheat a waffle iron to medium-high.",
            "Coat the waffle iron with nonstick cooking spray.",
            "Top each chaffle with a pat of butter and drizzle with maple syrup."
        ],
        description: "A chaffle is a low-carb, cheese-and-egg-based waffle...",
        prepTime: 120,
        difficulty: .easy,
        servingSize: 1,
        media: [
            "https://www.themerchantbaker.com/wp-content/uploads/2019/10/Basic-Chaffles-REV-Total-3-480x480.jpg",
            "https://thebestketorecipes.com/wp-content/uploads/2022/01/Easy-Basic-Chaffle-Recipe-Easy-Keto-Chaffle-5.jpg"
        ],
        chefsNotes: "String"
    )
    var body: some View {
        TabView(selection: $selectedView) {
            FeedView().tabItem {
                Image(systemName: "house")
            }
            .tag(TabSelection.home)
            CommunityView().tabItem {
                Image(systemName: "magnifyingglass")
            }.tag(TabSelection.search)
            AddRecipeMain().tabItem {

                Image(systemName: "plus.circle")
            }.tag(TabSelection.post)
            LeaderboardView().tabItem {
                Image(systemName: "trophy")
            }.tag(TabSelection.leaderboard)
            if let currentUser = authViewModel.currentUser {
                ProfileView(user: currentUser, isOwnProfile:true).tabItem {
                    Image(systemName: "person.circle")
                }.tag(TabSelection.profile)
            } else {
                ProgressView().tabItem {
                    Image(systemName: "person.circle")
                }.tag(TabSelection.profile)
            }
            
        }
    }
}

enum TabSelection: Hashable {
    case home, search, post, leaderboard, profile
}

#Preview {
    Home()
}
