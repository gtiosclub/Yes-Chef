//
//  RemixData.swift
//  Yes Chef
//
//  Created by Eesh Majithia on 10/9/25.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

// Eesh New Edit: Removed DummyNode class - now using real RemixTreeNode from RemixTreeModel.swift
// DummyNode has been replaced with RemixTreeNode throughout the codebase
// End of Eesh New Edit

// Eesh New Edit: Updated documentation to reflect use of real RemixTreeNode
/**
 * RemixData manages the remix tree data from Firebase's "realRemixTreeNodes" collection.
 *
 * This is the production-ready data manager that handles:
 * - Real-time listening to Firebase updates
 * - Fetching remix tree nodes from Firestore
 * - Managing the remix tree structure in the app
 *
 * Uses RemixTreeNode from RemixTreeModel.swift which is optimized for Firebase
 * with ID-based relationships instead of object references.
 */
// End of Eesh New Edit
@MainActor
class RemixData: ObservableObject {
    static let shared = RemixData()

    // Eesh New Edit: Changed from [DummyNode] to [RemixTreeNode]
    @Published var nodes : [RemixTreeNode] = []  // Real remix tree nodes from Firebase
    // End of Eesh New Edit

    private init() {

    }
    
    func recalibrateEntries(){
        // Fetch from Firebase after initialization
        fetchRemixNodes { nodes in
            DispatchQueue.main.async {
                self.nodes = nodes
            }
        }
    }
    
    func refreshData() async {
        while true{
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 seconds
            await MainActor.run {
                self.recalibrateEntries()
            }
        }
    }
    
    private var db = Firestore.firestore()
   

    //done
    // Eesh New Edit: Changed collection and DummyNode to RemixTreeNode
    func fetchRemixNodes(completion: @escaping ([RemixTreeNode]) -> Void) {
            db.collection("realRemixTreeNodes")
                .getDocuments { snapshot, error in
                    var nodes: [RemixTreeNode] = []
    // End of Eesh New Edit
                    
                    if let error = error {
                        print("Error fetching remix nodes:", error.localizedDescription)
                        completion(nodes)
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        completion(nodes)
                        return
                    }
                    
                    for doc in documents {
                        let data = doc.data()
                        
                        // Eesh New Edit: Changed DummyNode to RemixTreeNode
                        if let rootPostID = data["rootPostID"] as? String,
                           let parentID = data["parentID"] as? String,
                           let childrenIDs = data["childrenIDs"] as? [String],
                           let description = data["description"] as? String {

                            let node = RemixTreeNode(
                                currNodeID: doc.documentID,
                                parentNodeID: parentID,
                                rootNodeOfTreeID: rootPostID,
                                childrenIDs: childrenIDs,
                                descriptionOfRecipeChanges: description
                            )

                            nodes.append(node)
                        }
                        // End of Eesh New Edit
                    }
                    
                    completion(nodes)
                }
        }
    
    
    
    static func seedDummyNodes() {
        let db = Firestore.firestore()
            
        let descriptions = [
            "Added extra spices for flavor.",
            "Reduced cooking time by 10 minutes.",
            "Used almond milk instead of dairy.",
            "Swapped chicken for tofu.",
            "Made it gluten-free.",
            "Added caramelized onions.",
            "Simplified the sauce recipe.",
            "Baked instead of fried.",
            "Replaced sugar with honey.",
            "Used air fryer instead of oven."
        ]
        
        let numberOfTrees = 1
        let maxDepth = 4
        let maxChildrenPerNode = 8
        
        var allNodes: [String: [String: Any]] = [:]
        
        for treeIndex in 0..<numberOfTrees {
            let rootID = UUID().uuidString
            let rootNode: [String: Any] = [
                "rootPostID": rootID,
                "parentID": "none",
                "childrenIDs": [],
                "description": "Root recipe node \(treeIndex + 1)"
            ]
            allNodes[rootID] = rootNode
            
            // recursively generate children
            func generateChildren(for parentID: String, rootID: String, depth: Int) {
                guard depth < maxDepth else { return }
                
                let numChildren = Int.random(in: 1...maxChildrenPerNode)
                var childIDs: [String] = []
                
                for _ in 0..<numChildren {
                    let childID = UUID().uuidString
                    childIDs.append(childID)
                    
                    let childNode: [String: Any] = [
                        "rootPostID": rootID,
                        "parentID": parentID,
                        "childrenIDs": [],
                        "description": descriptions.randomElement() ?? "Tweaked the recipe."
                    ]
                    allNodes[childID] = childNode
                    
                    // recursively add next layer
                    generateChildren(for: childID, rootID: rootID, depth: depth + 1)
                }
                
                // update parent's childrenIDs
                if var parentNode = allNodes[parentID] {
                    parentNode["childrenIDs"] = childIDs
                    allNodes[parentID] = parentNode
                }
            }
            
            generateChildren(for: rootID, rootID: rootID, depth: 0)
        }
        
        // Now write to Firestore
        // Eesh New Edit: Changed collection to "realRemixTreeNodes"
        for (nodeID, data) in allNodes {
            db.collection("realRemixTreeNodes").document(nodeID).setData(data) { error in
                if let error = error {
                    print("Error writing node \(nodeID): \(error.localizedDescription)")
                } else {
                    print("Node \(nodeID) written successfully")
                }
            }
        }
        // End of Eesh New Edit
    }

    //done
    // Eesh New Edit: Changed collection to "realRemixTreeNodes"
    static func clearDummyNodes() {
        let db = Firestore.firestore()
        db.collection("realRemixTreeNodes").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            for doc in documents {
                db.collection("realRemixTreeNodes").document(doc.documentID).delete { err in
                    if let err = err {
                        print("Error deleting document \(doc.documentID): \(err.localizedDescription)")
                    } else {
                        print("Deleted document \(doc.documentID)")
                    }
                }
            }
        }
    }
    // End of Eesh New Edit
    
    private var listener: ListenerRegistration?

    // Eesh New Edit: Changed collection and DummyNode to RemixTreeNode
    func startListening() {
        listener?.remove() // stop old one if active
        listener = db.collection("realRemixTreeNodes").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error listening for updates: \(error?.localizedDescription ?? "unknown")")
                return
            }

            var nodes: [RemixTreeNode] = []
            for doc in snapshot.documents {
                let data = doc.data()
                if let rootPostID = data["rootPostID"] as? String,
                   let parentID = data["parentID"] as? String,
                   let childrenIDs = data["childrenIDs"] as? [String],
                   let description = data["description"] as? String {

                    let node = RemixTreeNode(
                        currNodeID: doc.documentID,
                        parentNodeID: parentID,
                        rootNodeOfTreeID: rootPostID,
                        childrenIDs: childrenIDs,
                        descriptionOfRecipeChanges: description
                    )
                    nodes.append(node)
                }
            }
    // End of Eesh New Edit
            
            DispatchQueue.main.async {
                self.nodes = nodes
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
