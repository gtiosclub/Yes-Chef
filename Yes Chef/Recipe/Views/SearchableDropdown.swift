//  SearchableDropdown.swift
//  Yes Chef
//
//  Created by RushilC on 9/30/25.
//

import SwiftUI

struct SearchableDropdownView<Option: SearchableOption>: View {
    @ObservedObject var viewModel: SearchableDropdownVM<Option>

    var body: some View {
        
        VStack(alignment: .leading) {
            TextField("Search...", text: $viewModel.query)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.2))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                .cornerRadius(10)
                .padding(.horizontal)

            if !viewModel.filteredOptions.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.filteredOptions, id: \.id) { option in
                            HStack {
                                Text(option.displayName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                if viewModel.isSelected(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .background(Color(.systemGray5))
                            .onTapGesture {
                                viewModel.toggleSelection(option)
                                viewModel.query = ""
                            }
                            Divider()
                                .padding(.leading, 12)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .frame(maxHeight: 100)
                
            }
        }
    }
}

struct SearchableDropdownView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            Text("Ingredients Search")
            SearchableDropdownView(
                viewModel: SearchableDropdownVM(options: Ingredient.allIngredients)
            )

        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
