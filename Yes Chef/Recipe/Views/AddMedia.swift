//
//  SwiftUIView.swift
//  Yes Chef
//
//  Created by Kairav Parikh on 9/30/25.
//

import SwiftUI
import PhotosUI

enum MediaType {
    case photo
    case video
}

struct MediaItem: Identifiable {
    let id: UUID = UUID()
    let image: Image?
    let localPath: URL
    let mediaType: MediaType
}

struct AddMedia: View {
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @Binding var mediaItems: [MediaItem]
    var onImageTap: ((Int) -> Void)?
    var padding: EdgeInsets = EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 12)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                PhotosPicker(
                    selection: $selectedPhotoItems,
                    matching: .any(of: [.images, .videos]),
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#F9F5F2"))
                            .frame(width: 120, height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#453A36"), lineWidth: 1)
                            )
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#453A36"))
                            .font(.system(size: 25))
                    }
                }
                .onChange(of: selectedPhotoItems) { newItems in
                    Task {
                        await loadAndSaveMedia(from: newItems)
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(mediaItems.indices, id: \.self) { index in
                            let item = mediaItems[index]
                            
                            ZStack(alignment: .topTrailing) {
                                if let image = item.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .cornerRadius(10)
                                        .clipped()
                                        .onTapGesture {
                                            onImageTap?(index)
                                        }
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            Image(systemName: "video.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 30))
                                        )
                                        .onTapGesture {
                                            onImageTap?(index)
                                        }
                                }
                            }
                        }
                    }
                }
                .frame(height: 120)
            }
        }
    }
    
    private func loadAndSaveMedia(from items: [PhotosPickerItem]) async {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("recipe_media_\(UUID().uuidString)")
        
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        for (index, item) in items.enumerated() {
            let fileName = "media_\(index)_\(UUID().uuidString)"
            
            if let imageData = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: imageData) {
                let image = Image(uiImage: uiImage)
                let imageURL = tempDir.appendingPathComponent(fileName).appendingPathExtension("jpg")
                
                do {
                    try imageData.write(to: imageURL)
                    let mediaItem = MediaItem(image: image, localPath: imageURL, mediaType: .photo)
                    mediaItems.append(mediaItem)
                    print("Saved photo locally: \(imageURL.path)")
                } catch {
                    print("Failed to save photo: \(error.localizedDescription)")
                }
            } else if let videoData = try? await item.loadTransferable(type: Data.self) {
                let videoURL = tempDir.appendingPathComponent(fileName).appendingPathExtension("mov")
                
                do {
                    try videoData.write(to: videoURL)
                    let mediaItem = MediaItem(image: nil, localPath: videoURL, mediaType: .video)
                    mediaItems.append(mediaItem)
                    print("Saved video locally: \(videoURL.path)")
                } catch {
                    print("Failed to save video: \(error.localizedDescription)")
                }
            }
        }
        
        selectedPhotoItems.removeAll()
    }
}

#Preview {
    @State var mediaItems: [MediaItem] = []
    return AddMedia(mediaItems: $mediaItems)
}
