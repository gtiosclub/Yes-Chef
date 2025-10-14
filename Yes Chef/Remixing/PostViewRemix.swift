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
    @State private var showRemixSheet = false
    @State private var remixVM: CreateRecipeVM? = nil


    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                // Header
                HStack(spacing: 6) {
                    // Back
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
                    ForEach(recipe.ingredients, id: \.self) { each in
                        BulletPointRemix(text: each, type: 1, num: 0)
                            .frame(maxHeight: 25)
                    }

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
        // ---- Floating Remix Button (bottom-right) ----
        .overlay(alignment: .bottomTrailing) {
            Button {
                remixVM = CreateRecipeVM.from(recipe: recipe)  // ⬅️ prefilled VM
                showRemixSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                    Text("Remix").fontWeight(.semibold)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Capsule().fill(.black.opacity(0.9)))
                .foregroundColor(.white)
                .shadow(radius: 8)
            }
            .padding(.trailing, 18)
            .padding(.bottom, 18)
        }
        .sheet(isPresented: $showRemixSheet) {
            if let vm = remixVM {
                NavigationStack {
                    CreateRecipe(recipeVM: vm)
                        .navigationTitle("Remix Recipe")
                        .navigationBarTitleDisplayMode(.inline)
                }
            } else {
                ProgressView("Loading…")
            }
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

// MARK: - Simple Remix Editor (prefilled from original recipe)
struct RemixEditor: View {
    let original: Recipe

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var description: String
    @State private var ingredients: String
    @State private var steps: String
    @State private var tags: String
    @State private var prepTime: String
    @State private var difficulty: Difficulty

    init(original: Recipe) {
        self.original = original
        _name = State(initialValue: original.name + " (Remix)")
        _description = State(initialValue: original.description)
        _ingredients = State(initialValue: original.ingredients.joined(separator: ", "))
        _steps = State(initialValue: original.steps.enumerated().map { "\($0+1). \($1)" }.joined(separator: "\n"))
        _tags = State(initialValue: original.tags.joined(separator: ", "))
        _prepTime = State(initialValue: "\(original.prepTime)")
        _difficulty = State(initialValue: original.difficulty)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Ingredients (comma-separated)") {
                    TextField("e.g. 2 eggs, 1 cup flour", text: $ingredients, axis: .vertical)
                }
                Section("Steps (one per line)") {
                    TextEditor(text: $steps)
                        .frame(minHeight: 120)
                }
                Section("Metadata") {
                    TextField("Tags (comma-separated)", text: $tags)
                    TextField("Prep time (mins)", text: $prepTime)
                        .keyboardType(.numberPad)
                    Picker("Difficulty", selection: $difficulty) {
                        Text("Easy").tag(Difficulty.easy)
                        Text("Medium").tag(Difficulty.medium)
                        Text("Hard").tag(Difficulty.hard)
                    }
                }
                Section {
                    Button(role: .none) {
                        // TODO: Wire to your save flow / view model.
                        // You can parse the strings back into arrays:
                        // let newIngredients = ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        // let newSteps = steps.split(separator: "\n").map(String.init)
                        // let newTags = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        dismiss()
                    } label: {
                        Label("Post Remix", systemImage: "sparkles")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Remix Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    let rec = Recipe(
        userId: "userid",
        recipeId: "recipeID",
        name: "Chaffle",
        ingredients: ["1 egg", "3 cups of flour", "1 teaspoon butter"],
        allergens: [""],
        tags: ["american", "keto", "gluten free"],
        steps: [
            "Preheat waffle iron to medium-high.",
            "Coat iron, add 1/4 cup batter per section.",
            "Top with butter and syrup."
        ],
        description: "A chaffle is a low-carb, cheese-and-egg-based waffle with fluffy texture and crispy edges.",
        prepTime: 120,
        difficulty: .easy,
        servingSize: 1,
        media: [
            "https://www.themerchantbaker.com/wp-content/uploads/2019/10/Basic-Chaffles-REV-Total-3-480x480.jpg",
            "https://thebestketorecipes.com/wp-content/uploads/2022/01/Easy-Basic-Chaffle-Recipe-Easy-Keto-Chaffle-5.jpg",
            ""
        ],
        chefsNotes: ""
    )
    PostViewRemix(recipe: rec, poster: nil)
}
