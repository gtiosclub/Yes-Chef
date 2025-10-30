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
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                Text("Hello Chef!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(20)
                
                HStack {
                    Button("For You") {}
                        .frame(width: 120, height: 20)
                        .padding()
                        .background(Color.gray.opacity(0.75))
                        .cornerRadius(40)
                        .foregroundColor(.white)
                    
                    Button("Following") {}
                        .frame(width: 120, height: 20)
                        .padding()
                        .background(Color.gray.opacity(0.75))
                        .cornerRadius(40)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                
                ScrollView {
                    if viewModel.recipes.isEmpty {
                        Text("No recipes available.")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.recipes) { recipe in
                                NavigationLink(destination: PostView(recipe: recipe)){
                                    VStack {
                                        if let firstImage = recipe.media.first,
                                           let url = URL(string: firstImage) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                
                                            } placeholder: {
                                                Color.gray.opacity(0.3)
                                            }
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(10)
                                            .clipped()
                                            
                                        } else {
                                            Color.gray.opacity(0.3)
                                                .frame(height: 150)
                                                .cornerRadius(10)
                                        }
                                        
                                        Text(recipe.name)
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                            .padding(.top, 5)
                                    }
                                    
                                }
                            }
                            
                        }
                        .padding()
                    }
                }
            }
            .task {
                do {
                    try await viewModel.fetchPosts()
                } catch {
                    print("Failed to fetch recipes: \(error)")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: UserListView()) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

#Preview {
    FeedView()
}
