//
//  Home.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/11/25.
//

import SwiftUI

struct Home: View {
    @State private var selectedView: TabSelection = .home
    @State private var navigationRecipe: Recipe? = nil
    @Environment(AuthenticationVM.self) var authVM
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            Group {
                switch selectedView {
                case .home:
                    FeedView()
                        .environment(authVM)
                case .search:
                    CommunityView()
                        .environment(authVM)
                case .post:
                    AddRecipeMain(selectedTab: $selectedView, navigationRecipe: $navigationRecipe)
                        .environment(authVM)
                case .leaderboard:
                    LeaderboardView()
                case .profile:
                    if let currentUser = authVM.currentUser {
                        ProfileView(user: currentUser, isOwnProfile: true)
                            .environment(authVM)
                    } else {
                        ProgressView()
                    }
                default:
                    FeedView()
                        .environment(authVM)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CustomBottomNavBar(selectedView: $selectedView)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            Task {
                await authVM.updateCurrentUser()
            }
        }
    }
}

struct CustomBottomNavBar: View {
    @Binding var selectedView: TabSelection
    
    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
            
            // Navigation buttons
            HStack(spacing: 0) {
                // Home
                NavBarButton(
                    icon: "house",
                    isSelected: selectedView == .home,
                    action: { selectedView = .home }
                )
                
                // Search
                NavBarButton(
                    icon: "magnifyingglass",
                    isSelected: selectedView == .search,
                    action: { selectedView = .search }
                )
                
                // Add Recipe
                NavBarButton(
                    icon: "plus.circle",
                    isSelected: selectedView == .post,
                    action: { selectedView = .post }
                )
                
                // Leaderboard
                NavBarButton(
                    icon: "trophy",
                    isSelected: selectedView == .leaderboard,
                    action: { selectedView = .leaderboard }
                )
                
                NavBarButton(
                    icon: "person.circle",
                    isSelected: selectedView == .profile,
                    action: { selectedView = .profile }
                )
            }
            .frame(height: 60)
            .padding(.bottom, 8)
        }
        .background(Color(hex: "#fffdf7"))
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct NavBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color(hex: "#D07436") : Color.gray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum TabSelection: Hashable {
    case home, search, post, leaderboard, messages, profile, remixtreedemo
}

#Preview {
    Home()
}
