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

// Eesh New Edit: DummyNode is the REAL RemixTreeNode implementation for Firebase
/**
 * DummyNode represents a node in the remix tree structure optimized for Firestore.
 *
 * This is the production-ready, functional RemixTreeNode class that works with
 * Firebase's "realRemixTreeNodes" collection. It uses a flattened structure with
 * ID references instead of direct object references, making it Codable and
 * compatible with Firestore's document-based storage.
 *
 * Unlike the RemixTreeNode class in RemixTreeModel.swift (which uses direct object
 * references), this class stores IDs for parent/children relationships, allowing
 * efficient serialization to/from Firestore.
 *
 * Collection: "realRemixTreeNodes" in Firebase
 */
class DummyNode: Identifiable, Codable, Hashable {
    let currNodeID: String          // Unique ID for this remix node (Recipe ID)
    var parentNodeID: String         // ID of parent recipe ("none" for root)
    let rootNodeOfTreeID: String     // ID of the root recipe in this tree
    var childrenIDs: [String]        // Array of child recipe IDs
    var descriptionOfRecipeChanges: String  // Description of changes in this remix
// End of Eesh New Edit

    init(
        currNodeID: String,
        parentNodeID: String,
        rootNodeOfTreeID: String,
        childrenIDs: [String],
        descriptionOfRecipeChanges: String = ""
    ) {
        self.currNodeID = currNodeID
        self.parentNodeID = parentNodeID
        self.rootNodeOfTreeID = rootNodeOfTreeID
        self.childrenIDs = childrenIDs
        self.descriptionOfRecipeChanges = descriptionOfRecipeChanges
    }

    static func == (lhs: DummyNode, rhs: DummyNode) -> Bool {
        lhs.currNodeID == rhs.currNodeID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(currNodeID)
    }
}



// Eesh New Edit: Added documentation explaining this is the real implementation
/**
 * RemixData manages the remix tree data from Firebase's "realRemixTreeNodes" collection.
 *
 * This is the production-ready data manager that handles:
 * - Real-time listening to Firebase updates
 * - Fetching remix tree nodes from Firestore
 * - Managing the remix tree structure in the app
 *
 * The nodes use DummyNode (the real RemixTreeNode implementation) which is
 * optimized for Firebase with ID-based relationships instead of object references.
 */
@MainActor
class RemixData: ObservableObject {
    static let shared = RemixData()

    @Published var nodes : [DummyNode] = []  // Real remix tree nodes from Firebase

    private init() {

    }
// End of Eesh New Edit
    
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
    // Eesh New Edit: Changed collection from "eeshRemixTreeNodes" to "realRemixTreeNodes"
    func fetchRemixNodes(completion: @escaping ([DummyNode]) -> Void) {
            db.collection("realRemixTreeNodes")
                .getDocuments { snapshot, error in
    // End of Eesh New Edit
                    var nodes: [DummyNode] = []
                    
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
                        
                        if let rootPostID = data["rootPostID"] as? String,
                           let parentID = data["parentID"] as? String,
                           let childrenIDs = data["childrenIDs"] as? [String],
                           let description = data["description"] as? String {
                            
                            let node = DummyNode(
                                currNodeID: doc.documentID,
                                parentNodeID: parentID,
                                rootNodeOfTreeID: rootPostID,
                                childrenIDs: childrenIDs,
                                descriptionOfRecipeChanges: description
                            )
                            
                            nodes.append(node)
                        }
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

    // Eesh New Edit: Changed collection to "realRemixTreeNodes"
    func startListening() {
        listener?.remove() // stop old one if active
        listener = db.collection("realRemixTreeNodes").addSnapshotListener { snapshot, error in
    // End of Eesh New Edit
            guard let snapshot = snapshot else {
                print("Error listening for updates: \(error?.localizedDescription ?? "unknown")")
                return
            }
            
            var nodes: [DummyNode] = []
            for doc in snapshot.documents {
                let data = doc.data()
                if let rootPostID = data["rootPostID"] as? String,
                   let parentID = data["parentID"] as? String,
                   let childrenIDs = data["childrenIDs"] as? [String],
                   let description = data["description"] as? String {
                    
                    let node = DummyNode(
                        currNodeID: doc.documentID,
                        parentNodeID: parentID,
                        rootNodeOfTreeID: rootPostID,
                        childrenIDs: childrenIDs,
                        descriptionOfRecipeChanges: description
                    )
                    nodes.append(node)
                }
            }
            
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
