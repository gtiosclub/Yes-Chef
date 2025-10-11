//  SearchableOption.swift
//  Yes Chef
//
//  Created by RushilC on 9/30/25.
//

import Foundation

protocol SearchableOption: Hashable, Identifiable {
    var displayName: String { get }
}

extension SearchableOption {
    var id: String { displayName }
}

enum SearchableValue<T: SearchableOption>: Hashable, Identifiable {
    case predefined(T)
    case custom(String)
    
    var displayName: String {
        switch self {
        case .predefined(let option):
            return option.displayName
        case .custom(let value):
            return value
        }
    }
    
    var id: String { displayName }
}
