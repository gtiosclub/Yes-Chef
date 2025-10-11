//
//  SwiftUIView.swift
//  Yes Chef
//
//  Created by Kairav Parikh on 9/30/25.
//

import SwiftUI
import PhotosUI

struct AddMedia: View {
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @Binding var selectedImages: [Image]
    @Binding var localMediaPaths: [URL]

    
    var body: some View {
        HStack(alignment: .top) {
            PhotosPicker(
                selection: $selectedPhotoItems,
                matching: .any(of: [.images, .videos]),
                photoLibrary: .shared()
            ) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray)
                        .frame(width: 120, height: 120)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 30, weight: .bold))
                }
            }
            .onChange(of: selectedPhotoItems) { newItems in
                Task {
                    await loadAndSaveMedia(from: newItems)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(selectedImages.indices, id: \.self) { index in
                        selectedImages[index]
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .cornerRadius(10)
                            .clipped()
                    }
                }
            }
            .frame(height: 120)
        }
    }
    
    private func loadAndSaveMedia(from items: [PhotosPickerItem]) async {
        selectedImages.removeAll()
        localMediaPaths.removeAll()
        
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("recipe_media_\(UUID().uuidString)")
        
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        for (index, item) in items.enumerated() {
            if let data = try? await item.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    let image = Image(uiImage: uiImage)
                    selectedImages.append(image)
                }
            
                let fileName = "media_\(index).jpg"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                do {
                    try data.write(to: fileURL)
                    localMediaPaths.append(fileURL)
                    print("Saved media locally: \(fileURL.path)")
                } catch {
                    print("Failed to save media locally: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func cleanupLocalMedia() {
        for path in localMediaPaths {
            let parentDir = path.deletingLastPathComponent()
            try? FileManager.default.removeItem(at: parentDir)
        }
        localMediaPaths.removeAll()
    }
}

#Preview {
    @State var imgs: [Image] = []
    @State var urls: [URL] = []
    return AddMedia(selectedImages: $imgs, localMediaPaths: $urls)
}
