//
//  temp.swift
//  Yes Chef
//
//  Created by Krish Prasad on 9/7/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                // Change Password Button
                Button(action: {
                    // Code to change password
                }) {
                    Text("Change Password")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Change Username Button
                Button(action: {
                    // Code to change username
                }) {
                    Text("Change Username")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Delete Account Button
                Button(action: {
                    // Code to delete account
                }) {
                    Text("Delete Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct FeedView: View {
    @State private var viewModel = PostViewModel()
    @State private var selectedTab: Tab = .forYou
    
    enum Tab {
        case forYou, following
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Different possible heights for visual variation
    let imageHeights: [CGFloat] = [160, 190, 220]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                
                // Title with icon
                HStack {
                    Text("Welcome Link!")
                        .font(.custom("Georgia", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#404741"))
                    
                    Spacer()
                    
                    Image(systemName: "paperplane")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#404741"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Custom tab bar - Z-stack overlapping style
                ZStack(alignment: .bottom) {
                    // Background for unselected tabs
                    Color(hex: "#F5F5F5")
                        .frame(height: 50)
                    
                    HStack(spacing: 0) {
                        // For You Tab
                        Button {
                            selectedTab = .forYou
                        } label: {
                            Text("For You")
                                .font(.custom("WorkSans-Regular", size: 16))
                                .foregroundColor(Color(hex: "#404741"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    GeometryReader { geo in
                                        Path { path in
                                            let w = geo.size.width
                                            let h = geo.size.height
                                            let cornerRadius: CGFloat = 8
                                            
                                            if selectedTab == .forYou {
                                                // Start bottom left
                                                path.move(to: CGPoint(x: 0, y: h))
                                                // Left side up
                                                path.addLine(to: CGPoint(x: 0, y: cornerRadius))
                                                // Top left curve
                                                path.addQuadCurve(
                                                    to: CGPoint(x: cornerRadius, y: 0),
                                                    control: CGPoint(x: 0, y: 0)
                                                )
                                                // Top side
                                                path.addLine(to: CGPoint(x: w - cornerRadius, y: 0))
                                                // Top right curve
                                                path.addQuadCurve(
                                                    to: CGPoint(x: w, y: cornerRadius),
                                                    control: CGPoint(x: w, y: 0)
                                                )
                                                // Right side down
                                                path.addLine(to: CGPoint(x: w, y: h))
                                                // Bottom
                                                path.addLine(to: CGPoint(x: 0, y: h))
                                            }
                                        }
                                        .fill(Color.white)
                                    }
                                )
                        }
                        .buttonStyle(.plain)
                        .zIndex(selectedTab == .forYou ? 1 : 0)
                        
                        // Following Tab
                        Button {
                            selectedTab = .following
                        } label: {
                            Text("Following")
                                .font(.custom("WorkSans-Regular", size: 16))
                                .foregroundColor(Color(hex: "#404741"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    GeometryReader { geo in
                                        Path { path in
                                            let w = geo.size.width
                                            let h = geo.size.height
                                            let cornerRadius: CGFloat = 8
                                            
                                            if selectedTab == .following {
                                                // Start bottom left
                                                path.move(to: CGPoint(x: 0, y: h))
                                                // Left side up
                                                path.addLine(to: CGPoint(x: 0, y: cornerRadius))
                                                // Top left curve
                                                path.addQuadCurve(
                                                    to: CGPoint(x: cornerRadius, y: 0),
                                                    control: CGPoint(x: 0, y: 0)
                                                )
                                                // Top side
                                                path.addLine(to: CGPoint(x: w - cornerRadius, y: 0))
                                                // Top right curve
                                                path.addQuadCurve(
                                                    to: CGPoint(x: w, y: cornerRadius),
                                                    control: CGPoint(x: w, y: 0)
                                                )
                                                // Right side down
                                                path.addLine(to: CGPoint(x: w, y: h))
                                                // Bottom
                                                path.addLine(to: CGPoint(x: 0, y: h))
                                            }
                                        }
                                        .fill(Color.white)
                                    }
                                )
                        }
                        .buttonStyle(.plain)
                        .zIndex(selectedTab == .following ? 1 : 0)
                    }
                }
                .frame(height: 50)
                
                // ScrollView for posts
                ScrollView {
                    if viewModel.recipes.isEmpty {
                        Text("No recipes available.")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.recipes, id: \.id) { recipe in
                                NavigationLink(destination: PostView(recipe: recipe)) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        let height = deterministicHeight(for: recipe.id.uuidHash)
                                        
                                        if let firstImage = recipe.media.first,
                                           let url = URL(string: firstImage) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                Color.gray.opacity(0.3)
                                            }
                                            .frame(width: 154, height: height)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .clipped()
                                        } else {
                                            Color.gray.opacity(0.3)
                                                .frame(width: 154, height: height)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        
                                        Text(recipe.name)
                                            .font(.custom("Inter-Regular", size: 12))
                                            .foregroundColor(Color(hex: "#404741"))
                                            .frame(width: 154, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                .background(Color.white)
            }
            .background(Color.white)
            .task {
                do {
                    try await viewModel.fetchPosts()
                } catch {
                    print("Failed to fetch recipes: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper
    private func deterministicHeight(for hash: Int) -> CGFloat {
        imageHeights[abs(hash) % imageHeights.count]
    }
}

extension String {
    var uuidHash: Int {
        unicodeScalars.map { Int($0.value) }.reduce(0, +)
    }
}
#Preview {
    FeedView()
}
