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
            FeedView().tabItem {
                Image(systemName: "house")
            }.tag(TabSelection.home)
            CommunityView().tabItem {
                Image(systemName: "magnifyingglass")
            }.tag(TabSelection.search)
            AddRecipeMain().tabItem {

                Image(systemName: "plus.circle")
            }.tag(TabSelection.post)
            LeaderboardView().tabItem {
                Image(systemName: "trophy")
            }.tag(TabSelection.leaderboard)
            ProfileView(isOwnProfile: true).tabItem {
                Image(systemName: "person.circle")
            }.tag(TabSelection.profile)
        }
    }
}

enum TabSelection: Hashable {
    case home, search, post, leaderboard, profile
}

#Preview {
    Home()
}
