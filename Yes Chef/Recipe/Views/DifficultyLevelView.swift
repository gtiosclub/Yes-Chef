//
//  DifficultyLevelView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 9/25/25.
//
import SwiftUI

struct DifficultyLevelView: View {
    @Binding var difficulty: Difficulty
    
    var body: some View {
        HStack(spacing: 16) {
            DifficultyButton(
                level: .easy,
                flameCount: 1,
                isSelected: difficulty == .easy
            ) {
                difficulty = .easy
            }
            
            DifficultyButton(
                level: .medium,
                flameCount: 2,
                isSelected: difficulty == .medium
            ) {
                difficulty = .medium
            }
            
            DifficultyButton(
                level: .hard,
                flameCount: 3,
                isSelected: difficulty == .hard
            ) {
                difficulty = .hard
            }
        }
        .animation(nil, value: difficulty)
    }
}

struct DifficultyButton: View {
    let level: Difficulty
    let flameCount: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack() {
                HStack(spacing: 4) {
                    ForEach(0..<flameCount, id: \.self) { _ in
                        Image(systemName: "flame.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(isSelected ? .orange : Color(hex: "#404741"))
                    }
                }
                
                Text(level.rawValue.capitalized)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.15) : Color(hex: "#F9F5F2"))
            )
        }
    }
}

#Preview {
    @Previewable @State var previewDifficulty: Difficulty = .easy
    
    DifficultyLevelView(difficulty: $previewDifficulty)
        .padding()
}
