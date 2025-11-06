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
        .padding(.vertical, 8)
        .background(Color(hex:"#F9F5F2"))
        .cornerRadius(15)
        .padding(.leading, 16.5)
        .padding(.trailing, 16.5)
    }
}

#Preview {
    ServingSizeView(selectedServingSize: .constant(5))
}
