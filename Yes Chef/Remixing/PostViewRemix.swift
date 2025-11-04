//
//  PostViewRemix.swift
//  Yes Chef
//
//  Created by Yifan Wang on 10/13/25.
//

import SwiftUI

private enum UIConst {
    static let screen = UIScreen.main.bounds
}

struct PostViewRemix: View {
    var recipe: Recipe
    var poster: User?

    @State private var mediaItem: Int? = 0
    @State private var goToAddRecipe = false

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                // Header
                HStack(spacing: 6) {
                    ZStack {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                    }

                    Spacer()

                    Text(recipe.name)
                        .font(.largeTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Image(systemName: "bookmark")
                        .font(.title2)

                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .frame(alignment: .trailing)
                }
                .padding(.bottom, UIConst.screen.width/50)

                // Author row
                HStack {
                    if let photoString = poster?.profilePhoto,
                       let profilePhoto = URL(string: photoString) {
                        AsyncImage(url: profilePhoto) { phase in
                            if let image = phase.image {
                                image
                                    .clipShape(Circle())
                                    .frame(width: 40, height: 40)
                            } else {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 40, height: 40)
                            }
                        }
                    } else {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 40, height: 40)
                    }

                    Text(poster?.username ?? "Username")
                    Spacer()

                    Button {} label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray3))
                                .frame(width: 80, height: 30)
                            Text("Follow").foregroundColor(.black)
                        }
                    }
                }

                // Media carousel
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(recipe.media.enumerated()), id: \.offset) { index, media in
                            AsyncImage(url: URL(string: media)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: UIConst.screen.width/1.2,
                                               height: UIConst.screen.height/2.5)
                                        .id(index)
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray3))
                                        .frame(width: UIConst.screen.width/1.2,
                                               height: UIConst.screen.height/2.5)
                                        .id(index)
                                }
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $mediaItem)

                // Page dots
                HStack(spacing: 1) {
                    ForEach(Array(recipe.media.enumerated()), id: \.offset) { index, _ in
                        if let mediaNum = mediaItem {
                            Text("•")
                                .font(.largeTitle)
                                .foregroundColor(index == mediaNum ? .black : .gray)
                        }
                    }
                }

                // Description
                Text(recipe.description).font(.body)

                // Meta row
                HStack {
                    let space = UIConst.screen.width/75
                    Image(systemName: "flame.fill")
                    Text(LocalizedStringKey(recipe.difficulty.id.prefix(1).uppercased() + recipe.difficulty.id.dropFirst()))
                        .padding(.trailing, space)

                    Image(systemName: "clock")
                    Text("\(recipe.prepTime) minutes")
                        .padding(.trailing, space)

                    Image(systemName: "person.fill")
                    Text("Serves \(recipe.servingSize) \(recipe.servingSize == 1 ? "person" : "people")")
                        .lineLimit(1)

                    Spacer()
                }
                .padding(.vertical, 10)

                // Ingredients + Instructions
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ingredients")
                        .font(.title)
                        .padding(.vertical, UIConst.screen.height/100)
//                    ForEach(recipe.ingredients, id: \.self) { each in
//                        BulletPointRemix(text: each, type: 1, num: 0)
//                            .frame(maxHeight: 25)
//                    }

                    Text("Instructions")
                        .font(.title)
                        .padding(.vertical, UIConst.screen.height/100)

                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, each in
                        BulletPointRemix(text: each, type: 2, num: index)
                    }
                }

                // Tags
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray5))
                                )
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.top, UIConst.screen.height/50)
            }
            .padding(15)
            .padding(.bottom, 80)
        }
        // Floating Remix Button + Navigation
        .overlay(alignment: .bottomTrailing) {
            NavigationLink("", isActive: $goToAddRecipe) {
                AddRecipeMain(remixRecipe: recipe)
            }
            .hidden()

            Button {
                goToAddRecipe = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles").font(.headline)
                    Text("Remix").fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.black))
                .foregroundColor(.white)
                .shadow(radius: 4, y: 2)
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
            .accessibilityLabel("Remix recipe")
        }
    }
}

struct BulletPointRemix: View {
    var text: String
    let type: Int
    var num: Int

    var body: some View {
        HStack {
            if type == 1 {
                Text("•").font(.largeTitle)
            } else if type == 2 {
                Text(String(format: "%02d", num))
                    .font(.title2)
                    .padding(.trailing, UIConst.screen.width/75)
            }
            Text(text)
                .font(.body)
                .padding(.bottom, UIConst.screen.height/100)
            Spacer()
        }
    }
}

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
        ],chefsNotes: "String",
        likes: 0)
    
    NavigationStack {
        PostViewRemix(recipe: rec, poster: nil)
    }
}
