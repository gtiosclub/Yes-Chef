//
//  DifficultyLevelView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 9/25/25.
//
import SwiftUI

struct DifficultyLevelView: View {
    @Binding var difficulty: Difficulty
    let OnClick: (Difficulty) -> Void
    
    var body: some View{
        HStack(spacing: 20){
            VStack(spacing: 10){
                
                Image(systemName: "flame.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80) .foregroundColor(difficulty == Difficulty.easy ? .red : .gray)
                                .onTapGesture {
                                    difficulty = Difficulty.easy
                                    OnClick(difficulty)
                                }
                Text(Difficulty.easy.rawValue).font(.headline)
            }
            VStack(spacing: 10){
                Image(systemName: "flame.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(difficulty == Difficulty.medium ? .red : .gray)
                                .onTapGesture {
                                    difficulty = Difficulty.medium
                                    OnClick(difficulty)
                                }
                Text(Difficulty.medium.rawValue).font(.headline)
            }
            VStack(spacing: 10){
                Image(systemName: "flame.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(difficulty == Difficulty.hard ? .red : .gray)
                                .onTapGesture {
                                    difficulty = Difficulty.hard
                                    OnClick(difficulty)
                                }
                Text(Difficulty.hard.rawValue).font(.headline)
            }
        }
    }
}
struct DifficultyLevelView_Previews: PreviewProvider {
    @State static var previewDifficulty: Difficulty = .easy

    static var previews: some View {
        DifficultyLevelView(difficulty: $previewDifficulty) { level in
            print("Clicked: \(level.rawValue)")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
