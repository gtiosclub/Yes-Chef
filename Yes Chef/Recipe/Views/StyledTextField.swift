//
//  StyledTextField.swift
//  Yes Chef
//
//  Created by Krish Prasad on 10/12/25.
//
import SwiftUI

struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    var height: CGFloat = 0
    var keyboardType: UIKeyboardType = .default
    var padding: EdgeInsets = EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 12)
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .font(.subheadline)
            .foregroundColor(Color(hex: "#877872"))
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#F9F5F2"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
    }
}
