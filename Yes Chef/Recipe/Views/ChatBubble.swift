//
//  ChatBubble.swift
//  Yes Chef
//
//  Created by RushilC on 10/28/25. #FFFDF4
//
import SwiftUI

struct ChatBubble: View {
    let message: SmartMessage

    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
                Text(message.text)
                    .padding(12)
                    .background(Color(hex: "#FFA947").opacity(0.2))
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#FFFDF4"))
                    .cornerRadius(0)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.sender == .user ? .trailing : .leading)
    }
}


