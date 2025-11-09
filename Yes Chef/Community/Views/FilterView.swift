import SwiftUI

struct FilterView: View {
    @Binding var show: Bool
    @Binding var selectedCuisine: Set<String>
    @Binding var selectedDietary: Set<String>
    @Binding var selectedDifficulty: Set<String>
    @Binding var selectedTime: Set<String>
    @Binding var selectedTags: Set<String>
    
    let cuisines = ["All", "Italian", "Mediterranean", "Chinese", "Japanese", "Korean", "Mexican"]
    let dietary = ["Any", "Vegetarian", "Vegan", "Halal", "Gluten-Free", "Keto", "Pescatarian"]
    let difficulties = ["Easy", "Medium", "Difficult"]
    let times = ["1 hr", "2 hr", "3 hr"]
    let tags = ["Egg", "Pasta", "Dumpling", "Soup"]
    
    var body: some View {
        VStack() {
            HStack {
                Text("Search Filters")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Clear") {
                    selectedCuisine.removeAll()
                    selectedDietary.removeAll()
                    selectedDifficulty.removeAll()
                    selectedTime.removeAll()
                    selectedTags.removeAll()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    FilterSection(title: "Cuisine") {
                        FilterOptions(items: cuisines, selection: $selectedCuisine)
                    }
                    FilterSection(title: "Dietary") {
                        FilterOptions(items: dietary, selection: $selectedDietary)
                    }
                    FilterSection(title: "Difficulty") {
                        FilterOptions(items: difficulties, selection: $selectedDifficulty)
                    }
                    FilterSection(title: "Time") {
                        FilterOptions(items: times, selection: $selectedTime)
                    }
                    FilterSection(title: "Tags") {
                        FilterOptions(items: tags, selection: $selectedTags)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            
            Spacer()
            
            Button(action: {
                show = false
            }) {
                Text("Apply Filters")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: 200)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(hex: "#fffdf7"))
    }
    
    
    
}

struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
    }
}

struct FilterBubble: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.orange : Color(.systemGray6))
                .foregroundColor(isSelected ? Color.white : Color.black)
                .cornerRadius(20)
        }
    }
}



struct FilterOptions: View {
    let items: [String]
    @Binding var selection: Set<String>
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 110))
            ], spacing: 8) {
                ForEach(items, id: \.self) { item in
                    FilterBubble(
                        text: item,
                        isSelected: selection.contains(item),
                        action: {
                            if selection.contains(item) {
                                selection.remove(item)
                            } else {
                                selection.insert(item)
                            }
                        }
                    )
                }
            }

        }
    }
}
