//
//  CaroulselView.swift
//  Yes Chef
//
//  Created by David Huang on 10/13/25.
//

import SwiftUI
import FirebaseStorage

struct CarouselView: View {
    var recipe: Recipe
    @StateObject private var viewModel = CarouselViewModel()
    
    @State private var childrenImages: [String] = []
    @State private var isLoaded = false
    
    let storage = Storage.storage()
    //let ref = storage.reference().child("recipes/\()/\(fileName)")
    
    var body: some View {
        Group {
            if isLoaded {
                if !childrenImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(childrenImages, id: \.self) { url in
                                AsyncImage(url: URL(string: url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 150, height: 150)
                                .cornerRadius(12)
                                .clipped()
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 150)
                            .cornerRadius(12)
                        Text("No Remix")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            } else {
                ProgressView()
                    .frame(height: 150)
            }
        }
        .task {
            childrenImages = await viewModel.fetchChildImages(for: recipe.recipeId)
            isLoaded = true
        }
    }
}
