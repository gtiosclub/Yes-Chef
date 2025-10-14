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

class DummyNode  {
    
    let currNodeID: String
    var parentNodeID: String
    let rootNodeOfTreeID: String
    
    var childrenIDs: [String]
    
    var descriptionOfRecipeChanges: String
    
    init(currNodeID: String,
         parentNodeID: String,
         rootNodeOfTreeID: String,
         childrenIDs: [String],
         descriptionOfRecipeChanges: String = "") {
        
        self.currNodeID = currNodeID
        self.parentNodeID = parentNodeID
        self.rootNodeOfTreeID = rootNodeOfTreeID
        self.childrenIDs = childrenIDs
        self.descriptionOfRecipeChanges = descriptionOfRecipeChanges
    }
    
}


@MainActor
class RemixData: ObservableObject {
    @Published var nodes : [DummyNode] = []

    init() {
       
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
    func fetchRemixNodes(completion: @escaping ([DummyNode]) -> Void) {
            db.collection("eeshRemixTreeNodes")
                .getDocuments { snapshot, error in
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
        let maxDepth = 2
        let maxChildrenPerNode = 3
        
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
                
                // update parent’s childrenIDs
                if var parentNode = allNodes[parentID] {
                    parentNode["childrenIDs"] = childIDs
                    allNodes[parentID] = parentNode
                }
            }
            
            generateChildren(for: rootID, rootID: rootID, depth: 0)
        }
        
        // Now write to Firestore
        for (nodeID, data) in allNodes {
            db.collection("eeshRemixTreeNodes").document(nodeID).setData(data) { error in
                if let error = error {
                    print("Error writing node \(nodeID): \(error.localizedDescription)")
                } else {
                    print("Node \(nodeID) written successfully")
                }
            }
        }
    }

    //done
    static func clearDummyNodes() {
        let db = Firestore.firestore()
        db.collection("eeshRemixTreeNodes").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for doc in documents {
                db.collection("eeshRemixTreeNodes").document(doc.documentID).delete { err in
                    if let err = err {
                        print("Error deleting document \(doc.documentID): \(err.localizedDescription)")
                    } else {
                        print("Deleted document \(doc.documentID)")
                    }
                }
            }
        }
    }
    
    private var listener: ListenerRegistration?

    func startListening() {
        listener?.remove() // stop old one if active
        listener = db.collection("eeshRemixTreeNodes").addSnapshotListener { snapshot, error in
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
