//
//  CarouselViewModel.swift
//  Yes Chef
//
//  Created by David Huang on 10/9/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class CarouselViewModel: ObservableObject, Identifiable {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func checkPostChildren(for postId: String) async -> Bool {
        do {
            let document = try await db.collection("REMIXTREENODES").document(postId).getDocument()
            guard let data = document.data() else { return false }
            
            let childrenIDs = data["childrenID"] as? [String] ?? []
            return !childrenIDs.isEmpty
        } catch {
            return false
        }
    }

    func fetchPostChildren(for postId: String) async -> [String] {
        do {
            let document = try await db.collection("REMIXTREENODES").document(postId).getDocument()
            guard let data = document.data() else { return [] }
            
            return data["childrenID"] as? [String] ?? []
        } catch {
            print("Error fetching child IDs:", error)
            return []
        }
    }
    
    func fetchChildImageURL(childID: String) async -> String? {
        do {
            let doc = try await db.collection("recipes").document(childID).getDocument()
            guard let data = doc.data(),
                  let media = data["media"] as? [String],
                  let firstURL = media.first,
                  !firstURL.isEmpty else { return nil }
            return firstURL
        } catch {
            print("Error fetching child image URL:", error)
            return nil
        }
    }

    func fetchChildImages(for postId: String) async -> [String] {
        let childIDs = await fetchPostChildren(for: postId)
        var urls: [String] = []
        
        for id in childIDs {
            if let url = await fetchChildImageURL(childID: id) {
                urls.append(url)
            }
        }
        return urls
    }
}
