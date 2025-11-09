//
//  Comment.swift
//  Yes Chef
//
//  Created by Ananya on 10/2/25.
//

import FirebaseFirestore
import SwiftUI
struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var poster: String
    var recipeID: String
    var text: String
    var timestamp: Date?
    
    init(poster: String, recipeID: String, text: String, timestamp: Date?) {
        self.poster = poster
        self.recipeID = recipeID
        self.text = text
        self.timestamp = timestamp
    }
}
