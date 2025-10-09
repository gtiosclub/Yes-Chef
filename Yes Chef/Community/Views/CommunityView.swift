//
//  CommunityView.swift
//  Yes Chef
//
//  Created by Kushi Kashyap on 9/20/25.
//
import SwiftUI

struct CommunityView : View {
    @State private var searchText = ""
    @State private var viewModel = SearchViewModel()
    
    let allItems = ["Pizza", "Pasta", "Salad", "Soup", "Sandwich", "Cake", "Curry"]

    var filteredItems: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return viewModel.usernames.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            Text("What's for Dinner?")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top, .leading], 20)
                .padding(.bottom, 5)
            ZStack {
                TextField("Search through the cookbook...", text: $searchText)
                    .padding(10)
                    .padding(.trailing, 30) // extra space for the icon
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    .padding(.horizontal)
                    
                HStack {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.trailing, 30) // match the extra padding in TextField
                }
            }
            Spacer()
            if !filteredItems.isEmpty {
                List(filteredItems, id: \.self) { item in Text(item)
                    .onTapGesture {searchText = item}
                }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        RecipeSection(title: "Trending", items: allItems)
                        RecipeSection(title: "Top Dinner Picks",items: allItems)
                        RecipeSection(title: "Top ... Picks",items: allItems)
                    }
                    .padding(.bottom, 20)
                }
                
            }
            Spacer()
        }
        .task {
            await viewModel.getAllUsernames()
        }
    }
}
struct RecipeSection: View {
    let title: String
    let items: [String]
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .padding(.horizontal, 20)
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    ForEach(items, id: \.self) { index in
                        RecipeCard(name: index)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct RecipeCard: View {
    let name: String
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(width: 160, height: 160)
                .overlay(Text(name))

        }
    }
}

#Preview {
    CommunityView()
}
