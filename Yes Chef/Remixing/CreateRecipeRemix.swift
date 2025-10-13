import SwiftUI

struct CreateRecipeRemix: View {
    @State private var userIdInput = ""
    @State private var name = ""
    @State private var description = ""
    @State private var ingredientsInput = ""
    @State private var allergensInput = ""
    @State private var tagsInput = ""             // stays as-is (not in Firestore sample)
    @State private var prepTimeInput = ""
    @State private var difficulty: Difficulty = .easy
    @State private var recipeVM = RecipeVM()
    @State private var statusMessage = ""
    @State private var steps: [String] = [""]
    @State private var mediaInputs: [String] = [""]
    @State private var FireBaseDemo = FirebaseDemo()

    // NEW: the ID to load
    @State private var recipeIdToLoad = "0832498E-D5BB-47AC-835A-0A1D7BD58BF9"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {

                    // --- Load by ID UI ---
                    Text("Load Existing Recipe by ID")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack {
                        TextField("Enter Firestore Document ID", text: $recipeIdToLoad)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .font(.subheadline)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))

                        Button("Load") { loadRecipeIntoFields() }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // --- Your existing fields ---
                    Text("Name").font(.title).padding().padding(.bottom, -40)
                    TextField("Enter Recipe Name", text: $name)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)

                    Text("Description").font(.title).padding().padding(.top,-20).padding(.bottom,-38)
                    TextField("Enter Recipe Description", text: $description)
                        .font(.subheadline)
                        .padding(10)
                        .padding(.bottom,90)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)

                    Text("Ingredients").font(.title).padding().padding(.top,-20).padding(.bottom,-38)
                    TextField("Enter Ingredients (Comma Separated)", text: $ingredientsInput)
                        .font(.subheadline)
                        .padding(10)
                        .padding(.bottom,30)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)

                    Text("Allergens").font(.title).padding().padding(.top,-20).padding(.bottom,-38)
                    TextField("Enter Allergens (Comma Separated)", text: $allergensInput)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)

                    Text("Tags").font(.title).padding().padding(.top,-20).padding(.bottom,-38)
                    TextField("Enter Tags (Comma Separated)", text: $tagsInput)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)

                    StepsInputView(steps: $steps)

                    Text("Prep Time").font(.title).padding().padding(.top,-20).padding(.bottom,-38)
                    TextField("Enter Prep Time in Minutes", text: $prepTimeInput)
                        .keyboardType(.numberPad)
                        .font(.subheadline)
                        .padding(10)
                        .foregroundColor(.primary)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        .padding()
                        .foregroundColor(.secondary)

                    Text("Media").font(.title).padding().padding(.top,-20)

                    Text("Difficulty").font(.title).padding().padding(.top,-20).padding(.bottom,-20)
                    Picker("Choose a Difficulty", selection: $difficulty) {
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
                    Button { } label: {
                        Image(systemName: "xmark").font(.title2).foregroundStyle(.red).bold()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            let ingredients = ingredientsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            let allergens = allergensInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            let tags = tagsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            let prepTime = Int(prepTimeInput) ?? 0

                            await recipeVM.createRecipe(
                                userId: userIdInput,
                                name: name,
                                ingredients: ingredients,
                                allergens: allergens,
                                tags: tags,
                                steps: steps,
                                description: description,
                                prepTime: prepTime,
                                difficulty: difficulty,
                                media: mediaInputs
                            )

                            await FireBaseDemo.addRecipeToRemixTreeAsRoot(description: description)
                        }
                    } label: {
                        Image(systemName: "checkmark").font(.title2).foregroundStyle(.gray).bold()
                    }
                }
            }
        }
    }

    // MARK: - Loader that maps Firestore data into the UI fields
    private func loadRecipeIntoFields() {
        fetchRecipeById(recipeIdToLoad) { recipe in
            guard let r = recipe else { return }
            DispatchQueue.main.async {
                name = r.name
                description = r.description
                ingredientsInput = r.ingredients.joined(separator: ", ")
                allergensInput = r.allergens.joined(separator: ", ")
                prepTimeInput = String(r.prepTime)
                steps = r.steps.isEmpty ? [""] : r.steps
                mediaInputs = r.media.isEmpty ? [""] : r.media
                // map difficulty string → your enum
                difficulty = Difficulty(rawValue: r.difficulty) ??
                             Difficulty(rawValue: r.difficulty.capitalized) ??
                             .easy
                // tags weren’t in your Firestore sample; keep current value
            }
        }
    }
}

#Preview { CreateRecipeRemix() }
