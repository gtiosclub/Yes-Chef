//
//  SearchableDropdownVM.swift
//  Yes Chef
//
//  Created by RushilC on 9/30/25.
//

import Foundation
import SwiftUI

class SearchableDropdownVM<Option: SearchableOption>: ObservableObject {
    @Published var query: String = ""
    @Published var selectedOptions: [Option] = []

    private var allOptions: [Option]

    init(options: [Option]) {
        self.allOptions = options
    }

    var filteredOptions: [Option] {
        if query.isEmpty { return [] }
        return allOptions.filter { $0.displayName.lowercased().contains(query.lowercased()) }
    }

    func toggleSelection(_ option: Option) {
        if selectedOptions.contains(option) {
            selectedOptions.removeAll { $0 == option }
        } else {
            selectedOptions.append(option)
        }
    }

    func isSelected(_ option: Option) -> Bool {
        selectedOptions.contains(option)
    }
}

