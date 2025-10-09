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


