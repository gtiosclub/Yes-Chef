//
//  Message.swift
//  Yes Chef
//
//  Created by Neel Bhattacharyya on 10/24/25.
//

import Foundation

enum Sender {
    case user
    case aiChef
}

struct SmartMessage: Identifiable {
    let id = UUID()
    let sender: Sender
    let text: String
    let title: String?
}
