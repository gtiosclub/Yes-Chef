
import SwiftUI

struct FilterView: View {
    @Binding var show: Bool
    var onApply: (String, Set<String>, Set<String>, Difficulty, Int, Set<String>, Bool) -> Void

    @State private var postVM = PostViewModel()
    
    // Filter selections
    @State private var searchText = ""
    @State private var selectedIngredients: [Ingredient] = []
    @State private var selectedAllergens: [SearchableValue<Allergen>] = []
    @State private var selectedTags: [SearchableValue<Tag>] = []
    @State private var selectedDifficulty: Difficulty = .none
    @State private var servingSize: Int = 1
    
    @State private var isFiltered: Bool = false
    
    @State var allIngredients: [Ingredient] = []

    // Derived ingredient list
    @State private var uniqueIngredients: [Ingredient] = []
    @State private var showSearchResults = false


    
    private let bgColor = Color(hex: "#F9F5F2")
    private let accentColor = Color(hex: "#453736")
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    ingredientsSection
                    allergensSection
                    tagsSection
                    servingSizeSection
                    difficultySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            applyButton
        }
        .background(bgColor)
        .task {
            await loadIngredientsFromRecipes()
        }

    }
}

extension FilterView {
    
    private var header: some View {
        HStack {
            Text("Search Filters")
                .font(.custom("Georgia", size: 24))
                .foregroundColor(accentColor)
            
            Spacer()
            
            Button("Clear") {
                selectedIngredients.removeAll()
                selectedAllergens.removeAll()
                selectedTags.removeAll()
                selectedDifficulty = .none
                servingSize = 1
            }
            .font(.custom("Work Sans", size: 14))
            .foregroundColor(Color(hex: "#7C887D"))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Ingredients")
            
            if uniqueIngredients.isEmpty {
                ProgressView("Loading ingredients…")
                    .padding(.vertical)
            } else {
                SearchableDropdown(
                    options: uniqueIngredients, // deduplicated ingredient list
                    selectedValues: Binding(
                        get: { selectedIngredients.map { SearchableValue.predefined($0) } },
                        set: { newValues in
                            selectedIngredients = newValues.compactMap {
                                switch $0 {
                                case .predefined(let ingredient): return ingredient
                                case .custom(let string): return Ingredient(name: string)
                                }
                            }
                        }
                    ),
                    placeholder: "Select or type ingredients",
                    allowCustom: true
                )
            }
        }
    }



    
    private var allergensSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Allergens")
            SearchableDropdown(
                options: Allergen.allCases,
                selectedValues: $selectedAllergens,
                placeholder: "Search allergens...",
                allowCustom: false
            )
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Tags")
            SearchableDropdown(
                options: Tag.allTags,
                selectedValues: $selectedTags,
                placeholder: "Search tags...",
                allowCustom: false
            )
        }
    }
    
    private var servingSizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Serving Size")
            ServingSizeView(selectedServingSize: $servingSize)
        }
    }
    
    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Difficulty")
            DifficultyLevelView(difficulty: $selectedDifficulty)
        }
    }
    
    private var applyButton: some View {
        VStack {

            Button(action: {

                show = false
                
                isFiltered = true
                onApply(
                    searchText,
                    Set(selectedIngredients.map { $0.name }),
                    Set(selectedAllergens.map { $0.displayName }),
                    selectedDifficulty,
                    servingSize,
                    Set(selectedTags.map { $0.displayName }),
                    isFiltered
                )
            }) {
                Text("Apply Filters")
                    .font(.custom("Work Sans", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(accentColor)
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
            
            NavigationLink(
                destination: SearchView(
                    searchText: searchText,
                    selectedIngredients: .constant(Set(selectedIngredients.map { $0.name })),
                    selectedAllergens: .constant(Set(selectedAllergens.map { $0.displayName })),
                    selectedDifficulty: .constant(selectedDifficulty),
                    selectedServingSize: .constant(servingSize),
                    selectedTags: .constant(Set(selectedTags.map { $0.displayName })),
                    hasAppliedFilters: $isFiltered
                )
                .environment(postVM),
                isActive: $showSearchResults
            ) {
                EmptyView()
            }

        }
    }
}

extension FilterView {
    private func loadIngredientsFromRecipes() async {
        do {
            try await postVM.fetchPosts()
            let allIngredients = postVM.recipes.flatMap { $0.ingredients }
            
            let uniqueNames = Set(allIngredients.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).capitalized })
            uniqueIngredients = uniqueNames.map { Ingredient(name: $0) }.sorted { $0.name < $1.name }
            
        } catch {
            print("❌ Error loading recipes: \(error.localizedDescription)")
        }
    }
}
