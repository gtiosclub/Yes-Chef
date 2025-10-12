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
        HStack() {
            Button(action: {
                selectedServingSize = max(0, selectedServingSize - 1)
            }) {
                Image(systemName: "minus")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(width: 25, height: 25)
            }
            
            Spacer()
            
            Text("\(selectedServingSize)")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                selectedServingSize += 1
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(width: 25, height: 25)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
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
