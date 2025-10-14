//
//  DifficultyLevelView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 9/25/25.
//
import SwiftUI

struct DifficultyLevelView: View {
    @Binding var difficulty: Difficulty
    
    var body: some View{
        HStack(spacing: 8){
            VStack(spacing: 10){
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42) .foregroundColor(difficulty == Difficulty.easy ? .red : .gray)
                    .onTapGesture {
                        difficulty = Difficulty.easy
                    }
                Text(Difficulty.easy.rawValue)
                    .font(.caption)
            }
            VStack(spacing: 10){
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .foregroundColor(difficulty == Difficulty.medium ? .red : .gray)
                    .onTapGesture {
                        difficulty = Difficulty.medium
                    }
                Text(Difficulty.medium.rawValue)
                    .font(.caption)
            }
            VStack(spacing: 10){
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .foregroundColor(difficulty == Difficulty.hard ? .red : .gray)
                    .onTapGesture {
                        difficulty = Difficulty.hard
                                }
                Text(Difficulty.hard.rawValue)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    @Previewable @State var previewDifficulty: Difficulty = .easy
    
    DifficultyLevelView(difficulty: $previewDifficulty)
        .padding()
}
