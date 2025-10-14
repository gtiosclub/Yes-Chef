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
            let allSearchableItems = allItems + viewModel.usernames
            return allSearchableItems.filter { $0.localizedCaseInsensitiveContains(searchText)}
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Hi Chef!")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .leading], 20)
                    .padding(.bottom, 5)
                ZStack {
                    TextField("Search...", text: $searchText)
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
                if !filteredItems.isEmpty {
                    List(filteredItems, id: \.self) { item in
                        if let selectedUser = viewModel.users.first(where: { $0.username == item }) {
                            NavigationLink(destination: ProfileView(user: selectedUser)) {
                                Text(item)
                            }
                        } else {
                            Text(item)
                            .onTapGesture {searchText = item}
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
                    Spacer()
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
                await viewModel.getAllUsers()
                await viewModel.getAllUsernames()
            }
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
