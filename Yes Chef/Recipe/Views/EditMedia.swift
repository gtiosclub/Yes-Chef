//
//  EditMedia.swift
//  Yes Chef
//
//  Created by Kairav Parikh on 10/18/25.
//

import SwiftUI

struct EditMedia: View {
    @Environment(\.dismiss) private var dismiss  

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(.leading)
                }

                Spacer()

                Text("Edit Media")
                    .font(.title)
                    .bold()

                Spacer()
            }
            .padding(.vertical)
            .background(Color.white.shadow(radius: 2))

            Spacer()

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 300, height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black, lineWidth: 2)
                )
                .padding()

            Text("Video Trimming Controls")
                .frame(width: 300, height: 50)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
                .padding(.top, 10)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        EditMedia()
    }
}

