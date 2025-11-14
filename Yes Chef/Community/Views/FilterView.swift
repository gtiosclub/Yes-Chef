import SwiftUI

struct PillLabel: View {
    let title: String
    var isSelected: Bool
    var action: () -> Void

    private let bgPage = Color(hex: "#FFFDF7")
    private let unselectedBorder = Color(hex: "#FFA947")
    private let selectedFill = Color(hex: "#FFCB88")

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Work Sans", size: 16))
                .foregroundColor(isSelected ? bgPage : unselectedBorder)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isSelected ? selectedFill : bgPage)
                .overlay(
                    Capsule()
                        .stroke(unselectedBorder, lineWidth: isSelected ? 0 : 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct ExpandablePillSection: View {
    let title: String
    let allItems: [String]
    @Binding var selected: Set<String>
    var initiallyExpanded: Bool = false
    var maxCollapsedCount: Int = 8

    @State private var expanded: Bool = false

    var body: some View {
        let cleanedItems = allItems
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.custom("Georgia", size: 20))
                    .foregroundStyle(Color(hex: "#453736"))
                    //.fontWeight(.semibold)
                Spacer()
                if cleanedItems.count > maxCollapsedCount {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            expanded.toggle()
                        }
                    }) {
                        Text(expanded ? "Show less ▲" : "Show more ▼")
                            .font(.custom("Work Sans", size: 14))
                            .foregroundColor(Color(hex: "#7C887D"))
                    }
                    .buttonStyle(.plain)
                }
            }

            let itemsToShow: [String] = {
                if expanded || cleanedItems.count <= maxCollapsedCount {
                    return cleanedItems
                } else {
                    return Array(cleanedItems.prefix(maxCollapsedCount))
                }
            }()

            FlowLayout(verticalSpacing: 8, horizontalSpacing: 8) {
                ForEach(itemsToShow, id: \.self) { item in
                    PillLabel(title: item, isSelected: selected.contains(item)) {
                        if selected.contains(item) {
                            selected.remove(item)
                        } else {
                            selected.insert(item)
                        }
                    }
                }
            }
        }
        .onAppear {
            expanded = initiallyExpanded
        }
    }
}


struct FilterView: View {
    @Binding var show: Bool
    var onApply: (String, Set<String>, Set<String>, Difficulty, Int, Set<String>, Int?, Int?, Bool) -> Void

    @State private var postVM = PostViewModel()

    @State private var searchText = ""
    @State private var selectedIngredients: [Ingredient] = []
    @State private var selectedAllergens: Set<String> = []
    @State private var selectedTags: Set<String> = []
    @State private var selectedDifficulty: Difficulty = .none
    @State private var servingSize: Int = 1
    @State private var minPrepTime: Int? = nil
    @State private var maxPrepTime: Int? = nil

    @State private var isFiltered: Bool = false

    @State private var uniqueIngredients: [Ingredient] = []
    @State private var showSearchResults = false

    private let bgColor = Color(hex: "#F9F5F2")
    private let accentColor = Color(hex: "#453736")
    private let pillUnselectedBorder = Color(hex: "#FFA947")
    private let pillSelectedFill = Color(hex: "#FFCB88")
    private let pillPageBg = Color(hex: "#FFFDF7")
    private let sectionSubtle = Color(hex: "#7C887D")

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                        ingredientsSectionAsPills

                        allergensSectionAsPills

                        tagsSectionAsPills
                        
                        difficultySectionAsPills

                        prepTimeSection
                        
                        servingSizeSection


                    } else {
                        searchResultsGrouped
                    }
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
        HStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "#FFA947"))

                TextField("Search", text: $searchText)
                    .font(.custom("Work Sans", size: 16))
                    .foregroundColor(.primary)
            }
            .padding(12)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#FFA947"), lineWidth: 1)
            )
            .cornerRadius(12)

            // Clear button
            Button("Clear") {
                selectedIngredients.removeAll()
                selectedAllergens.removeAll()
                selectedTags.removeAll()
                selectedDifficulty = .none
                servingSize = 1
                minPrepTime = nil
                maxPrepTime = nil
                searchText = ""
                isFiltered = false
            }
            .font(.custom("Work Sans", size: 14))
            .foregroundColor(Color(hex: "#7C887D"))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }



    private var ingredientsSectionAsPills: some View {
        ExpandablePillSection(
            title: "Ingredients",
            allItems: uniqueIngredients.map { $0.name },
            selected: Binding(get: {
                Set(selectedIngredients.map { $0.name })
            }, set: { newSet in
                selectedIngredients = newSet.map { Ingredient(name: $0) }.sorted { $0.name < $1.name }
            }),
            initiallyExpanded: false,
            maxCollapsedCount: 8
        )
    }

    private var allergensSectionAsPills: some View {
        ExpandablePillSection(
            title: "Allergens",
            allItems: Allergen.allCases.map { $0.rawValue },
            selected: $selectedAllergens,
            initiallyExpanded: false,
            maxCollapsedCount: 8
        )
    }

    private var tagsSectionAsPills: some View {
        ExpandablePillSection(
            title: "Tags",
            allItems: Tag.allTagStrings,
            selected: $selectedTags,
            initiallyExpanded: false,
            maxCollapsedCount: 8
        )
    }

    private var difficultySectionAsPills: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Difficulty")
                .font(.custom("Georgia", size: 20))
                .foregroundStyle(Color(hex: "#453736"))
                //.fontWeight(.semibold)

            HStack(spacing: 10) {
                ForEach(Difficulty.allCases.filter { $0 != .none }, id: \.self) { d in
                    PillLabel(title: d.rawValue, isSelected: selectedDifficulty == d) {
                        if selectedDifficulty == d {
                            selectedDifficulty = .none
                        } else {
                            selectedDifficulty = d
                        }
                    }
                }
            }
        }
    }

    private var servingSizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Serving Size")
                .font(.custom("Georgia", size: 20))
                .foregroundStyle(Color(hex: "#453736"))
                //.fontWeight(.semibold)

            ServingSizeView(selectedServingSize: $servingSize)
                .padding(.horizontal, 0)
        }
    }

    private var prepTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prep & Cook Time")
                .font(.custom("Georgia", size: 20))
                .foregroundStyle(Color(hex: "#453736"))
               // .fontWeight(.semibold)

            HStack(spacing: 12) {
                TextField("Min (minutes)", value: $minPrepTime, format: .number)
                    .keyboardType(.numberPad)
                    .font(.custom("Work Sans", size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#FFFDF7"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#FFA947"), lineWidth: 1)
                    )
                    .cornerRadius(14)

                Text("to")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(Color(hex: "#7C887D"))

                TextField("Max (minutes)", value: $maxPrepTime, format: .number)
                    .keyboardType(.numberPad)
                    .font(.custom("Work Sans", size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#FFFDF7"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#FFA947"), lineWidth: 1)
                    )
                    .cornerRadius(14)
            }
        }
    }

    private var applyButton: some View {
        VStack {
            Button(action: {
                let hasAnyFilter = !selectedIngredients.isEmpty
                    || !selectedAllergens.isEmpty
                    || !selectedTags.isEmpty
                    || selectedDifficulty != .none
                    || servingSize > 1
                    || (minPrepTime != nil)
                    || (maxPrepTime != nil)
                    || !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                isFiltered = hasAnyFilter

                onApply(
                    "",
                    Set(selectedIngredients.map { $0.name }),
                    selectedAllergens,
                    selectedDifficulty,
                    servingSize,
                    selectedTags,
                    minPrepTime,
                    maxPrepTime,
                    isFiltered
                )

                show = false
            }) {
                Text("Apply Filters")
                    .font(.custom("Work Sans", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
        }
    }

    private var searchResultsGrouped: some View {
        VStack(alignment: .leading, spacing: 18) {
            let ingredientMatches = uniqueIngredients
                .map { $0.name }
                .filter { $0.localizedCaseInsensitiveContains(searchText) }
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            if !ingredientMatches.isEmpty {
                Text("Ingredients")
                    .font(.custom("Georgia", size: 20))
                    .foregroundColor(accentColor)

                FlowLayout(verticalSpacing: 8, horizontalSpacing: 8) {
                    ForEach(ingredientMatches, id: \.self) { name in
                        PillLabel(title: name, isSelected: Set(selectedIngredients.map { $0.name }).contains(name)) {
                            if let idx = selectedIngredients.firstIndex(where: { $0.name == name }) {
                                selectedIngredients.remove(at: idx)
                            } else {
                                selectedIngredients.append(Ingredient(name: name))
                            }
                        }
                    }
                }
            }


            let allergenMatches = Allergen.allCases
                .map { $0.rawValue }
                .filter { $0.localizedCaseInsensitiveContains(searchText) }
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            if !allergenMatches.isEmpty {
                Text("Allergens")
                    .font(.custom("Georgia", size: 20))
                    .foregroundColor(accentColor)

                FlowLayout(verticalSpacing: 8, horizontalSpacing: 8) {
                    ForEach(allergenMatches, id: \.self) { name in
                        PillLabel(title: name, isSelected: selectedAllergens.contains(name)) {
                            if selectedAllergens.contains(name) {
                                selectedAllergens.remove(name)
                            } else {
                                selectedAllergens.insert(name)
                            }
                        }
                    }
                }
            }


            let tagMatches = Tag.allTags
                .map { $0.rawValue }
                .filter { $0.localizedCaseInsensitiveContains(searchText) }
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            if !tagMatches.isEmpty {
                Text("Tags")
                    .font(.custom("Georgia", size: 20))
                    .foregroundColor(accentColor)

                FlowLayout(verticalSpacing: 8, horizontalSpacing: 8) {
                    ForEach(tagMatches, id: \.self) { name in
                        PillLabel(title: name, isSelected: selectedTags.contains(name)) {
                            if selectedTags.contains(name) {
                                selectedTags.remove(name)
                            } else {
                                selectedTags.insert(name)
                            }
                        }
                    }
                }
            }


            let difficultyMatches = Difficulty.allCases
                .filter { $0 != .none }
                .map { $0.rawValue }
                .filter { $0.localizedCaseInsensitiveContains(searchText) }
            if !difficultyMatches.isEmpty {
                Text("Difficulty")
                    .font(.custom("Georgia", size: 20))
                    .foregroundColor(accentColor)

                HStack(spacing: 10) {
                    ForEach(Difficulty.allCases.filter { $0 != .none }, id: \.self) { d in
                        if difficultyMatches.contains(d.rawValue) {
                            PillLabel(title: d.rawValue, isSelected: selectedDifficulty == d) {
                                if selectedDifficulty == d {
                                    selectedDifficulty = .none
                                } else {
                                    selectedDifficulty = d
                                }
                            }
                        }
                    }
                }
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
