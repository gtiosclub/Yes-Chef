//
//  HistoryBlock.swift
//  Yes Chef
//
//  Created by Nidhi Krishna on 9/20/25.
//
import SwiftUI
import FirebaseFirestore

struct HistoryBlock: Identifiable, Equatable {
    let id: String // Firebase document ID
    var date: String
    var challengeName: String
    var submissions: [String] // Array of recipe IDs
    var archivedAt: Date?

    // Convenience initializer for backward compatibility
    init(id: String = UUID().uuidString, date: String, challengeName: String, submissions: [String] = [], archivedAt: Date? = nil) {
        self.id = id
        self.date = date
        self.challengeName = challengeName
        self.submissions = submissions
        self.archivedAt = archivedAt
    }
}
