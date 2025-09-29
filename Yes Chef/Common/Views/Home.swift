//
//  Home.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/11/25.
//

import Foundation
import SwiftUI

struct Home: View {
    @State var selectedView: TabSelection = .home
    var body: some View {
        
        TabView(selection: $selectedView) {
            tempFeed().tabItem {
                Image(systemName: "house")
            }.tag(TabSelection.home)
            CommunityView().tabItem {
                Image(systemName: "magnifyingglass")
            }.tag(TabSelection.search)
            /*posting_temp().tabItem {
                Image(systemName: "plus.circle")
            }.tag(TabSelection.post)*/
            LeaderboardView().tabItem {
                Image(systemName: "trophy")
            }.tag(TabSelection.leaderboard)
            SettingsView().tabItem {
                Image(systemName: "person.circle")
            }.tag(TabSelection.profile)
        }
    }
}

enum TabSelection {
    case home, search, post, leaderboard, profile
}

#Preview {
    Home()
}
