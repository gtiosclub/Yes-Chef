//  RecipeView.swift
//  Yes Chef
//
//  Created by RushilC on 9/20/25.
//

import SwiftUI

struct CreateRecipe: View {
    @State private var recipeVM = CreateRecipeVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.title)
                        .padding()
                        .padding(.bottom, -40)

                    TextField("Enter Recipe Name", text: $recipeVM.name)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)

                    Text("Description")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)

                    TextField("Enter Recipe Description", text: $recipeVM.description)
                        .font(.subheadline)
                        .padding(10)
                        .padding(.bottom,90)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)

                    Text("Ingredients")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)

                    TextField(
                        "Enter Ingredients (Comma Separated)",
                        text: Binding(get: { recipeVM.ingredientsInput }, set: { recipeVM.onIngredientsChanged($0) })
                    )
                    .font(.subheadline)
                    .padding(10)
                    .padding(.bottom,30)
                    .foregroundColor(.primary)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .padding()
                    .foregroundColor(.secondary)

                    Text("Allergens")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)

                    TextField(
                        "Enter Allergens (Comma Separated)",
                        text: Binding(get: { recipeVM.allergensInput }, set: { recipeVM.onAllergensChanged($0) })
                    )
                    .font(.subheadline)
                    .padding(10)
                    .foregroundColor(.primary)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .padding()
                    .foregroundColor(.secondary)

                    Text("Tags")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)

                    TextField(
                        "Enter Tags (Comma Separated)",
                        text: Binding(get: { recipeVM.tagsInput }, set: { recipeVM.onTagsChanged($0) })
                    )
                    .font(.subheadline)
                    .padding(10)
                    .foregroundColor(.primary)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .padding()
                    .foregroundColor(.secondary)

                    StepsInputView(steps: $recipeVM.steps)

                    Text("Prep Time")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)

                    TextField("Enter Prep Time in Minutes", text: $recipeVM.prepTimeInput)
                        .keyboardType(.numberPad)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)

                    Text("Media")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)

                    Text("Difficulty")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom,-20)

                    Picker("Choose a Difficulty", selection: $recipeVM.difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {} label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.red)
                            .bold()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await recipeVM.createRecipe(
                                userId: recipeVM.userIdInput,
                                name: recipeVM.name,
                                ingredients: recipeVM.ingredients,
                                allergens: recipeVM.allergens,
                                tags: recipeVM.tags,
                                steps: recipeVM.steps,
                                description: recipeVM.description,
                                prepTime: recipeVM.prepTime,
                                difficulty: recipeVM.difficulty,
                                media: recipeVM.mediaInputs
                            )
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundStyle(.gray)
                            .bold()
                    }
                }
            }
        }
    }
}

#Preview { CreateRecipe() }
