//  RecipeView.swift
//  Yes Chef
//
//  Created by RushilC on 9/20/25.
//

import SwiftUI

struct CreateRecipe: View {
    @StateObject private var vm = CreateRecipeScreenVM()
    @State private var recipeVM = RecipeVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.title)
                        .padding()
                        .padding(.bottom, -40)

                    TextField("Enter Recipe Name", text: $vm.name)
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

                    TextField("Enter Recipe Description", text: $vm.description)
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
                        text: Binding(get: { vm.ingredientsInput }, set: { vm.onIngredientsChanged($0) })
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
                        text: Binding(get: { vm.allergensInput }, set: { vm.onAllergensChanged($0) })
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
                        text: Binding(get: { vm.tagsInput }, set: { vm.onTagsChanged($0) })
                    )
                    .font(.subheadline)
                    .padding(10)
                    .foregroundColor(.primary)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .padding()
                    .foregroundColor(.secondary)

                    StepsInputView(steps: $vm.steps)

                    Text("Prep Time")
                        .font(.title)
                        .padding()
                        .padding(.top,-20)
                        .padding(.bottom, -38)

                    TextField("Enter Prep Time in Minutes", text: $vm.prepTimeInput)
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

                    Picker("Choose a Difficulty", selection: $vm.difficulty) {
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
                                userId: vm.userIdInput,
                                name: vm.name,
                                ingredients: vm.ingredients,
                                allergens: vm.allergens,
                                tags: vm.tags,
                                steps: vm.steps,
                                description: vm.description,
                                prepTime: vm.prepTime,
                                difficulty: vm.difficulty,
                                media: vm.mediaInputs
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
