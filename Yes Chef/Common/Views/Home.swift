//
//  Home.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/11/25.
//

import SwiftUI

struct Home: View {
    @State private var selectedView: TabSelection = .home

    var body: some View {
        TabView(selection: $selectedView) {

            FeedView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(TabSelection.home)

            CommunityView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(TabSelection.search)

            // Post tab should open CreateRecipe (not CommunityView)
            CreateRecipe()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Post")
                }
                .tag(TabSelection.post)

            LeaderboardView()
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Leaders")
                }
                .tag(TabSelection.leaderboard)

            ProfileView(isOwnProfile: true)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(TabSelection.profile)
        }
    }
}

enum TabSelection: Hashable {
    case home, search, post, leaderboard, profile
}

#Preview {
    Home()
}
