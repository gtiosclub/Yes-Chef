//
//  ChatBubble.swift
//  Yes Chef
//
//  Created by RushilC on 10/28/25. #FFFDF4
//
import SwiftUI

struct ChatBubble: View {
    let message: SmartMessage
    var onViewChanges: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 8) {
            if message.sender == .aiChef, let title = message.title, let onViewChanges = onViewChanges {
                Button(action: onViewChanges) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#404741"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("See recipe changes")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#7C887DF2"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#FFFFFC"))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(hex: "#D8D3C5"), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
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
                        .padding(.horizontal, 10)
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cornerRadius(0)
                }
            }
            .frame(maxWidth: .infinity, alignment: message.sender == .user ? .trailing : .leading)
        }
    }
}


