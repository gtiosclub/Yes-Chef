//
//  HistoryViewModel.swift
//  Yes Chef
//
//  Created by Nidhi Krishna on 9/22/25.
//

import FirebaseFirestore
import SwiftUI

@Observable
class HistoryViewModel: ObservableObject {
    var history: [HistoryBlock] = []
    private var db = Firestore.firestore()


    func fetchHistory() {
        db.collection("CHALLENGEHISTORY")
            .order(by: "archivedAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching challenge history: \(error)")
                    return
                }

                DispatchQueue.main.async {
                    self.history = snapshot?.documents.compactMap { doc in
                        let data = doc.data()
                        let prompt = data["prompt"] as? String ?? "Unknown Challenge"
                        let submissions = data["submissions"] as? [String] ?? []

                        // Format date
                        var dateString = "Unknown Date"
                        if let timestamp = data["archivedAt"] as? Timestamp {
                            let date = timestamp.dateValue()
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            dateString = formatter.string(from: date)
                        }

                        return HistoryBlock(
                            id: doc.documentID,
                            date: dateString,
                            challengeName: prompt,
                            submissions: submissions,
                            archivedAt: (data["archivedAt"] as? Timestamp)?.dateValue()
                        )
                    } ?? []
                }
            }
    }
}
