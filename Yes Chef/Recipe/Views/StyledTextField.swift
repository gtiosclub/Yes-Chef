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
    var previewRemoving: [String] = []
    var previewAdding: [String] = []
    
    private var previewState: PreviewState {
        // Check if current text matches something being removed
        let isRemoving = previewRemoving.contains { removing in
            text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == removing.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Check if current text matches something being added
        let isAdding = previewAdding.contains { adding in
            text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == adding.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // For text fields, if there's a new value being added, show green
        // If the current value is being removed, show red
        if isRemoving {
            return .removing
        } else if isAdding || (!previewAdding.isEmpty && text.isEmpty) {
            return .adding
        } else {
            return .normal
        }
    }
    
    private var backgroundColor: Color {
        switch previewState {
        case .removing:
            return Color.red.opacity(0.2)
        case .adding:
            return Color.green.opacity(0.2)
        case .normal:
            return Color(hex: "#F9F5F2")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
                        .fill(backgroundColor)
                )
            
            // Show preview additions below the field
            if !previewAdding.isEmpty && text.isEmpty {
                ForEach(previewAdding, id: \.self) { addingValue in
                    Text(addingValue)
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.2))
                        )
                }
            }
        }
        .padding(.horizontal)
    }
}

private enum PreviewState {
    case removing
    case adding
    case normal
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
