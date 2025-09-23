//
//  AIViewModel.swift
//  Yes Chef
//
//  Created by Nitya Potti on 9/22/25.
//

import Foundation
import FirebaseFirestore

class AIViewModel: ObservableObject {
    @Published var openaiKey: String?
    let db = Firestore.firestore()
    init()  {
        fetchAPIKey()
    }
    private func fetchAPIKey() {
        Task {
            do {
                let document = try await db.collection("APIKEYS").document("OpenAI").getDocument()
                if let data = document.data(), let key = data["key"] as? String {
                    DispatchQueue.main.async {
                        self.openaiKey = key
                    }
                } else {
                    print("No key found in document")
                }
            } catch {
                print("Error fetching API key from Firestore: \(error)")
            }
        }
    }
}
