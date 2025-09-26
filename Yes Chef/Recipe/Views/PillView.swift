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
    case ingredients(Ingredient)
    
    var displayName: String {
            switch self {
            case .tags(let tag): return tag.rawValue.capitalized
            case .ingredients(let ingredient): return ingredient.rawValue.capitalized
            case .allergens(let allergen): return allergen.rawValue.capitalized
            }
        }
}

struct PillView: View {
    let value: AcceptedTypes
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
                Text(value.displayName)
                .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                        )
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
    }
struct PillView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            PillView(value: .tags(.flavor(.spicy))) {}
            PillView(value: .ingredients(.vegetable(.tomato))) { }
            PillView(value: .allergens(.nuts)) { }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
