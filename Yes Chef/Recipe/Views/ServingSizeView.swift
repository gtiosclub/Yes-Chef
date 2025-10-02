//
//  ServingSizeView.swift
//  Yes Chef
//
//  Created by Asutosh Mishra on 9/30/25.
//
import SwiftUI

struct ServingSizeView: View {
    @Binding var selectedServingSize: ServingSize
        
    var body: some View {
        Menu {
            Picker("Serving Size", selection: $selectedServingSize) {
                ForEach(ServingSize.allCases) { serving in
                    Text("\(serving.rawValue)").tag(serving)
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                
                Text("\(selectedServingSize.rawValue)")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
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
}
#Preview {
    ServingSizeView(selectedServingSize: .constant(ServingSize.five))
}
