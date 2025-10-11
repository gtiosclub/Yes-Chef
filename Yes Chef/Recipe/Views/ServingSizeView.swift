//
//  ServingSizeView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 9/30/25.
//
import SwiftUI

struct ServingSizeView: View {
    @Binding var selectedServingSize: Int
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                selectedServingSize = max(0, selectedServingSize - 1)
            }) {
                Image(systemName: "minus")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text("\(selectedServingSize)")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                selectedServingSize += 1
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color(uiColor: .systemGray5))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.primary, lineWidth: 2)
        )
    }
}

#Preview {
    ServingSizeView(selectedServingSize: .constant(5))
}
