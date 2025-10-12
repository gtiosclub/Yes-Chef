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
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .font(.subheadline)
            .padding(10)
            .padding(.bottom, height)
            .foregroundColor(.primary)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            .padding(.horizontal)
    }
}
