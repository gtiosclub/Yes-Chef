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
        db.collection("leaderboardHistory").getDocuments { snapshot, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
            DispatchQueue.main.async {
                
                
                self.history = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    let title = data["Title"] as? String ?? "Unknown"
                    let challengeName = data["Challenge"] as? String ?? "Unknown"
                    
                    return HistoryBlock(date: title, challengeName: challengeName)
                } ?? []
            }
        }
    }
}
