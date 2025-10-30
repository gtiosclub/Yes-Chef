//
//  Home.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/11/25.
//

import SwiftUI

struct Home: View {
    @State private var selectedView: TabSelection = .home
    @Environment(AuthenticationVM.self) var authVM
    var body: some View {
        TabView(selection: $selectedView) {
            FeedView().tabItem {
                Image(systemName: "house")
            }
            .tag(TabSelection.home)
            .environment(authVM)
            CommunityView().tabItem {
                Image(systemName: "magnifyingglass")
            }
            .tag(TabSelection.search)
            AddRecipeMain().tabItem {
                Image(systemName: "plus.circle")
            }
            .tag(TabSelection.post)
            .environment(authVM)
            LeaderboardView().tabItem {
                Image(systemName: "trophy")
            }
            .tag(TabSelection.leaderboard)
            if let currentUser = authVM.currentUser {
                ProfileView(user: currentUser, isOwnProfile:true).tabItem {
                    Image(systemName: "person.circle")
                }
                .tag(TabSelection.profile)
                .environment(authVM)
            } else {
                ProgressView().tabItem {
                    Image(systemName: "person.circle")
                }.tag(TabSelection.profile)
            }
//            RemixTreeView().tabItem {
//                Image(systemName: "tree")
//            }
//            .tag(TabSelection.remixtreedemo)
            
        }
        .onAppear {
            Task {
                await authVM.updateCurrentUser()
            }
        }
    }
}

enum TabSelection: Hashable {
    case home, search, post, leaderboard, messages, profile, remixtreedemo
}

#Preview {
    Home()
}
