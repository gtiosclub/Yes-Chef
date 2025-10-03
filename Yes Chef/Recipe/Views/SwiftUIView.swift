//
//  SwiftUIView.swift
//  Yes Chef
//
//  Created by Kairav Parikh on 9/30/25.
//

import SwiftUI
import PhotosUI

struct SwiftUIView: View {
    @StateObject private var recipeVM = RecipeVM()
    
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var uploadedURLs: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text("Add Media")
                .font(.headline)
            
            HStack(alignment: .top, spacing: 20) {
                VStack(spacing: 12) {
                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        matching: .any(of: [.images, .videos]),
                        photoLibrary: .shared()
                    ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.gray)
                                .frame(width: 100, height: 100)
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 30, weight: .bold))
                        }
                    }
                    .onChange(of: selectedPhotoItems) { newItems in
                        Task {
                            await loadPreviews(from: newItems)
                        }
                    }
                    
                    Button("Confirm Media") {
                        Task {
                            await uploadSelectedMedia()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            selectedImages[index]
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                                .clipped()
                        }
                    }
                }
                .frame(height: 120) 
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private func loadPreviews(from items: [PhotosPickerItem]) async {
        selectedImages.removeAll()
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                let image = Image(uiImage: uiImage)
                selectedImages.append(image)
            }
        }
    }
    
    private func uploadSelectedMedia() async {
        uploadedURLs.removeAll()
        
        let recipeUUID = UUID().uuidString
        
        for (index, item) in selectedPhotoItems.enumerated() {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let fileName = "media_\(index).jpg"
                
                if let urlString = await recipeVM.uploadMediaData(
                    data,
                    fileName: fileName,
                    recipeUUID: recipeUUID
                ) {
                    uploadedURLs.append(urlString)
                }
            }
        }
        
        print("Uploaded Media URLs:", uploadedURLs)
        
        let _ = await recipeVM.createRecipe(
            userId: "test",
            name: "Test Recipe",
            ingredients: ["Ingredient1"],
            allergens: [],
            tags: ["Tag1"],
            steps: ["Step 1"],
            description: "A sample recipe",
            prepTime: 10,
            difficulty: .easy,
            media: uploadedURLs
        )
    }
}

#Preview {
    SwiftUIView()
}
