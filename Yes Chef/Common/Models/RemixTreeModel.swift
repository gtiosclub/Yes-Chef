//
//  RemixTreeModel.swift
//  Yes Chef
//
//  Created by Nitya Potti on 9/25/25.
//

import Foundation
import Firebase

// Eesh New Edit: Restored original RemixTreeNode with object references
//node in the remix tree
class RemixTreeNode  {

    let currNodeID: String
    var postName: String
    var parentNode: RemixTreeNode?
    let rootNodeOfTree: RemixTreeNode

    var children: [RemixTreeNode]

    var descriptionOfRecipeChanges: String

    init(currNodeID: String,
         postName: String,
         parentNode: RemixTreeNode?,
         rootNodeOfTree: RemixTreeNode,
         children: [RemixTreeNode],
         descriptionOfRecipeChanges: String = "") {

        self.currNodeID = currNodeID
        self.postName = postName
        self.parentNode = parentNode
        self.rootNodeOfTree = rootNodeOfTree
        self.children = children
        self.descriptionOfRecipeChanges = descriptionOfRecipeChanges
    }
}
// End of Eesh New Edit

// Eesh New Edit: Created FirebaseRemixTreeNode wrapper - depends completely on RemixTreeNode
/**
 * FirebaseRemixTreeNode is a Firebase-compatible wrapper that DEPENDS COMPLETELY on RemixTreeNode.
 *
 * This class exists SOLELY to serialize RemixTreeNode to Firebase. It extracts IDs from
 * RemixTreeNode's object references (parentNode, children, rootNodeOfTree) and stores them
 * as ID strings (parentNodeID, childrenIDs, rootNodeOfTreeID) for Firestore compatibility.
 *
 * IMPORTANT: FirebaseRemixTreeNode is essentially DummyNode but now properly references
 * and depends on the real RemixTreeNode class. All data is extracted from RemixTreeNode.
 *
 * Conversion: Use `FirebaseRemixTreeNode(from: remixTreeNode)` to extract IDs from RemixTreeNode
 *
 * Collection: "realRemixTreeNodes" in Firebase
 */
class FirebaseRemixTreeNode: Identifiable, Codable, Hashable {
    let currNodeID: String              // Unique ID for this remix node (Recipe ID)
    var postName: String
    var parentNodeID: String            // ID of parent recipe ("none" for root)
    let rootNodeOfTreeID: String        // ID of the root recipe in this tree
    var childrenIDs: [String]           // Array of child recipe IDs
    var descriptionOfRecipeChanges: String  // Description of changes in this remix

    init(currNodeID: String,
         postName: String,
         parentNodeID: String,
         rootNodeOfTreeID: String,
         childrenIDs: [String],
         descriptionOfRecipeChanges: String = "") {

        self.currNodeID = currNodeID
        self.postName = postName
        self.parentNodeID = parentNodeID
        self.rootNodeOfTreeID = rootNodeOfTreeID
        self.childrenIDs = childrenIDs
        self.descriptionOfRecipeChanges = descriptionOfRecipeChanges
    }

    // Convert from RemixTreeNode to FirebaseRemixTreeNode
    convenience init(from node: RemixTreeNode) {
        self.init(
            currNodeID: node.currNodeID,
            postName: node.postName,
            parentNodeID: node.parentNode?.currNodeID ?? "none",
            rootNodeOfTreeID: node.rootNodeOfTree.currNodeID,
            childrenIDs: node.children.map { $0.currNodeID },
            descriptionOfRecipeChanges: node.descriptionOfRecipeChanges
        )
    }

    static func == (lhs: FirebaseRemixTreeNode, rhs: FirebaseRemixTreeNode) -> Bool {
        lhs.currNodeID == rhs.currNodeID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(currNodeID)
    }
}
// End of Eesh New Edit

// Eesh New Edit: Restored original RemixTree structure
// remix tree itself
class RemixTree {

    var rootNode: RemixTreeNode?

    init(nodeID: String, postName: String, parentNode: RemixTreeNode?, rootNodeOfTree: RemixTreeNode, children: [RemixTreeNode], descriptionOfRecipeChanges: String = "") {

        self.rootNode = RemixTreeNode(currNodeID: nodeID,
                                      postName: postName,
                                          parentNode: nil,
                                          rootNodeOfTree: rootNodeOfTree,
                                          children: children)
    }

    /**
    Should delete a node from the remix tree. If a node is deleted and it has children, the parent of the children get reassigned to the parent of the deleted node.
     */
    func deleteNode(node: RemixTreeNode) {
        guard let parent = node.parentNode else {
            for child in node.children {
                child.parentNode = nil
            }
            node.children.removeAll()
            node.parentNode = nil
            self.rootNode = nil

            return
        }

        for child in node.children {
            child.parentNode = parent
            parent.children.append(child)
        }

        if let index = parent.children.firstIndex(where: { child in child === node }) {
            parent.children.remove(at: index)
        }

        node.children.removeAll()
        node.parentNode = nil
    }
// End of Eesh New Edit

    /**
            Handles node deletion in firebase
     */

    // Eesh New Edit: Updated to use REMIXTREENODES collection
    static func deleteNodeFirebase(nodeId: String) {
        let nodeRef = Firebase.db.collection("REMIXTREENODES").document(nodeId)
    // End of Eesh New Edit

        
        nodeRef.getDocument { (document, error) in
            if let error = error {
                print("Error checking document: \(error.localizedDescription)")
                return
            }
            
            if let node = document, node.exists {

                
                // Eesh New Edit: Updated field names and collection references
                if let children = node.get("childrenIDs") as? [String] {
                    //asumes children are valid
                    if let parent = node.get("parentID") as? String {
                        let parentRef = Firebase.db.collection("REMIXTREENODES").document(parent)

                        for childID in children {
                            let childRef = Firebase.db.collection("REMIXTREENODES").document(childID)
                            childRef.updateData([
                                "parentID": parent
                            ])


//                if let children = node.get("childrenID") as? [String] {
//                    //asumes children are valid
//                    if let parent = node.get("parentID") as? String, !parent.isEmpty {
//                        let parentRef = Firebase.db.collection("REMIXTREENODES").document(parent)
//
//                        for childID in children {
//                                guard !childID.isEmpty else { continue } // <--- skip empty strings
//                                let childRef = Firebase.db.collection("REMIXTREENODES").document(childID)
//                                childRef.updateData([
//                                    "parentID": parent
//                                ])

                        }

                        parentRef.updateData([
                            "childrenIDs": FieldValue.arrayUnion(children)
                        ])

                        parentRef.updateData([
                            "childrenIDs": FieldValue.arrayRemove([nodeId])
                        ])

                        nodeRef.delete()
                    } else {

                        print("'parentID' field is missing or not a string")

//                       //root node
//                        for childID in children {
//                                guard !childID.isEmpty else { continue } // <--- skip empty strings
//                                let childRef = Firebase.db.collection("REMIXTREENODES").document(childID)
//                                childRef.updateData([
//                                    "parentID": nil,
//                                    "rootNodeID": childID
//                                ])
//                        }
//                        
//                        nodeRef.delete()

                    }

                } else {
                    print("'childrenIDs' field is missing or not an array of strings")
                }
                // End of Eesh New Edit
                

            } else {
                print("Document does not exist — nothing to delete.")
            }
        }
    }
    
    // Eesh New Edit: Restored original addNode and findNode methods
    func addNode(nodeID: String, postName: String, parentNode: RemixTreeNode?, rootNodeOfTree: RemixTreeNode, children: [RemixTreeNode], descriptionOfRecipeChanges: String = "") {

        let newNode = RemixTreeNode(currNodeID: nodeID,
                                    postName: postName,
                                    parentNode: parentNode,
                                    rootNodeOfTree: rootNodeOfTree,
                                    children: children,
                                    descriptionOfRecipeChanges: descriptionOfRecipeChanges)
        parentNode?.children.append(newNode)
    }

    func findNode(nodeID: String) -> RemixTreeNode? {
        guard let rootNode = rootNode else { return nil }
        return findNodeHelper(currNode: rootNode, destNodeID: nodeID)
    }

    private func findNodeHelper(currNode: RemixTreeNode, destNodeID: String) -> RemixTreeNode? {

        if currNode.currNodeID == destNodeID {
            return currNode
        }


        for childNode in currNode.children {

            if let found = findNodeHelper(currNode: childNode, destNodeID: destNodeID) {
                return found
            }
        }

        return nil
    }
    // End of Eesh New Edit
}
