//  SearchableDropdown.swift
//  Yes Chef
//
//  Created by RushilC on 9/30/25.
//

import SwiftUI

struct SearchableDropdown<Option: SearchableOption>: View {
    let options: [Option]
    @Binding var selectedOptions: [Option]
    let placeholder: String
    
    @State private var searchQuery = ""
    @State private var isExpanded = false
    
    private var filteredOptions: [Option] {
        guard !searchQuery.isEmpty else { return [] }
        return options.filter { option in
            !selectedOptions.contains(option) &&
            option.displayName.lowercased().contains(searchQuery.lowercased())
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                
                TextField(placeholder, text: $searchQuery)
                    .font(.system(size: 15))
                
                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .padding(.horizontal)
            
            if !filteredOptions.isEmpty {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(filteredOptions, id: \.id) { option in
                            Button(action: {
                                toggleSelection(option)
                            }) {
                                HStack(spacing: 12) {
                                    Text(option.displayName)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemBackground))
                            }
                            
                            if option.id != filteredOptions.last?.id {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
            
            if !selectedOptions.isEmpty {
                FlowLayout() {
                    ForEach(selectedOptions, id: \.id) { option in
                        if let acceptedType = toAcceptedType(option) {
                            PillView(value: acceptedType) {
                                withAnimation {
                                    removeSelection(option)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: filteredOptions.isEmpty)
    }
    
    private func toggleSelection(_ option: Option) {
        selectedOptions.append(option)
        searchQuery = ""
    }
    
    private func removeSelection(_ option: Option) {
        selectedOptions.removeAll { $0 == option }
    }
    
    private func toAcceptedType(_ option: Option) -> AcceptedTypes? {
        if let ingredient = option as? Ingredient {
            return .ingredients(ingredient)
        } else if let allergen = option as? Allergen {
            return .allergens(allergen)
        } else if let tag = option as? Tag {
            return .tags(tag)
        }
        return nil
    }
}



