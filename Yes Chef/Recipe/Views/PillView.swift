//
//  PillView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 9/23/25.
//


import SwiftUI

enum AcceptedTypes {
    case tags(Tag)
    case allergens(Allergen)
    case customString(String)
    
    var displayName: String {
        switch self {
        case .tags(let tag): return tag.rawValue.capitalized
        case .allergens(let allergen): return allergen.rawValue.capitalized
        case .customString(let string): return string
        }
    }
}

struct PillView: View {
    let value: AcceptedTypes
    let onClick: () -> Void
    var isRemoving: Bool = false
    var isAdding: Bool = false
    
    private var backgroundColor: Color {
        if isRemoving {
            return Color.red.opacity(0.3)
        } else if isAdding {
            return Color.green.opacity(0.3)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private var foregroundColor: Color {
        if isRemoving {
            return Color.red
        } else if isAdding {
            return Color.green
        } else {
            return Color.gray
        }
    }
    
    var body: some View {
        Button(action: onClick) {
            Text(value.displayName)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(backgroundColor)
                )
                .foregroundColor(foregroundColor)
        }
        .buttonStyle(.plain)
    }
}


struct PillView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            PillView(value: .tags(.flavor(.spicy))) {}
            PillView(value: .allergens(.nuts)) { }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
