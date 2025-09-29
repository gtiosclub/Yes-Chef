//
//  CommunityView.swift
//  Yes Chef
//
//  Created by Kushi Kashyap on 9/20/25.
//
import SwiftUI

struct CommunityView : View {
    @State private var searchText = ""
    
    let allItems = ["Pizza", "Pasta", "Salad", "Soup", "Sandwich", "Cake", "Curry"]

    var filteredItems: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return allItems.filter { $0.localizedCaseInsensitiveContains(searchText) }
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
            if !filteredItems.isEmpty {
                List(filteredItems, id: \.self) { item in Text(item)
                    .onTapGesture {searchText = item}
                }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
            }
            Spacer()
        }
    }
}

#Preview {
    CommunityView()
}
