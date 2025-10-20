//  SearchableDropdown.swift
//  Yes Chef
//
//  Created by RushilC on 9/30/25.
//

import SwiftUI

struct SearchableDropdown<Option: SearchableOption>: View {
    let options: [Option]
    @Binding var selectedValues: [SearchableValue<Option>]
    let placeholder: String
    let allowCustom: Bool
    
    @State private var searchQuery = ""
    
    private var filteredOptions: [Option] {
        guard !searchQuery.isEmpty else { return [] }
        let selectedDisplayNames = Set(selectedValues.map { $0.displayName.lowercased() })
        return options.filter { option in
            !selectedDisplayNames.contains(option.displayName.lowercased()) &&
            option.displayName.lowercased().contains(searchQuery.lowercased())
        }
    }
    
    private var shouldShowCustomOption: Bool {
        guard allowCustom && !searchQuery.isEmpty else { return false }
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return false }
        
        let selectedDisplayNames = Set(selectedValues.map { $0.displayName.lowercased() })
        if selectedDisplayNames.contains(query.lowercased()) {
            return false
        }
        
        return !options.contains { $0.displayName.lowercased() == query.lowercased() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                    .stroke(Color(.black), lineWidth: 1)
            )
            .padding(.horizontal)
            
            if !(filteredOptions.isEmpty && !shouldShowCustomOption) {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(filteredOptions, id: \.id) { option in
                            Button(action: {
                                selectPredefined(option)
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
                        
                        if shouldShowCustomOption {
                            Button(action: {
                                selectCustom(searchQuery)
                            }) {
                                HStack(spacing: 12) {
                                    Text(searchQuery)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemBackground))
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
            
            if !selectedValues.isEmpty {
                FlowLayout() {
                    ForEach(selectedValues, id: \.id) { value in
                        if let acceptedType = toAcceptedType(value) {
                            PillView(value: acceptedType) {
                                removeSelection(value)
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
    
    private func selectPredefined(_ option: Option) {
        selectedValues.append(.predefined(option))
        searchQuery = ""
    }
        
    private func selectCustom(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        selectedValues.append(.custom(trimmed))
        searchQuery = ""
    }
    
    private func removeSelection(_ value: SearchableValue<Option>) {
        selectedValues.removeAll { $0 == value }
    }
    
    private func toAcceptedType(_ value: SearchableValue<Option>) -> AcceptedTypes? {
        switch value {
        case .predefined(let option):
            if let allergen = option as? Allergen {
                return .allergens(allergen)
            } else if let tag = option as? Tag {
                return .tags(tag)
            }
        case .custom(let string):
            return .customString(string)
        }
        return nil
    }
}



