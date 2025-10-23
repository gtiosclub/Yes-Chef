//
//  EditMedia.swift
//  Yes Chef
//
//  Created by Kairav Parikh on 10/18/25.
//

import SwiftUI
import AVKit

struct EditMedia: View {
    let image: UIImage?
    let videoURL: URL?

    var body: some View {
        VStack {
            HStack {
                Text("Edit Media")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding()

            Spacer()

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding()
            } else if let videoURL = videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(width: 300, height: 300)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black, lineWidth: 2))
                    .padding()
            }

            Text("Video Trimming Controls")
                .frame(width: 300, height: 50)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
                .padding(.top, 10)

            Spacer()
        }
    }
}

