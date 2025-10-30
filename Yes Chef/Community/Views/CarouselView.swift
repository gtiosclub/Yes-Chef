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
/*
#Preview {
    let rec = Recipe(
        userId: "zvUtxNaS4FRTC1522AsZLxCXl5s1",
        recipeId: "recipeID",
        name: "Chaffle",
        ingredients: [
            Ingredient(name: "egg", quantity: 1, unit: "", preparation: ""),
            Ingredient(name: "flour", quantity: 3, unit: "cups", preparation: ""),
            Ingredient(name: "butter", quantity: 1, unit: "teaspoon", preparation: "")
        ],
        allergens: [""],
        tags: ["american", "keto", "gluten free"],
        steps: [
            "Preheat a waffle iron to medium-high. Whisk the eggs in a large bowl until well beaten and smooth.",
            "Coat the waffle iron with nonstick cooking spray, then ladle a heaping 1/4 cup of batter into each section.",
            "Top each chaffle with a pat of butter and drizzle with maple syrup."
        ],
        description: "A chaffle is a low-carb, cheese-and-egg-based waffle that's taken the keto world by storm, thanks to its fluffy texture and crispy edges.",
        prepTime: 120,
        difficulty: .easy,
        servingSize: 1,
        media: [
            "https://www.themerchantbaker.com/wp-content/uploads/2019/10/Basic-Chaffles-REV-Total-3-480x480.jpg",
            "https://thebestketorecipes.com/wp-content/uploads/2022/01/Easy-Basic-Chaffle-Recipe-Easy-Keto-Chaffle-5.jpg",
            ""
        ],
        chefsNotes: "String"
    )
    
    CarouselView(recipe: rec)
}
*/
