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
        TextField("", text: $text)
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundColor(Color(hex: "#7C887DF2"))
                    .font(.subheadline)
            }
            .keyboardType(keyboardType)
            .font(.subheadline)
            .foregroundColor(Color(hex: "#404741"))
            .padding(padding)
            .padding(.bottom, height)
            .background(
                RoundedRectangle(cornerRadius: 17)
                    .fill(Color(hex: "#F9F5F2"))
            )
            .padding(.horizontal)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
