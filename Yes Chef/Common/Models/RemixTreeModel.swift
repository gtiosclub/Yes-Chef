//
//  RemixTreeModel.swift
//  Yes Chef
//
//  Created by Nitya Potti on 9/25/25.
//

import Foundation
import Firebase

// Eesh New Edit: Updated RemixTreeNode to be Firebase-compatible using ID-based relationships
/**
 * RemixTreeNode represents a node in the remix tree structure.
 *
 * This is the real, production-ready RemixTreeNode class that works with
 * Firebase's "realRemixTreeNodes" collection. It uses ID references for
 * parent/children relationships to enable Firestore serialization.
 *
 * Collection: "realRemixTreeNodes" in Firebase
 */
class RemixTreeNode: Identifiable, Codable, Hashable {
    let currNodeID: String              // Unique ID for this remix node (Recipe ID)
    var parentNodeID: String            // ID of parent recipe ("none" for root)
    let rootNodeOfTreeID: String        // ID of the root recipe in this tree
    var childrenIDs: [String]           // Array of child recipe IDs
    var descriptionOfRecipeChanges: String  // Description of changes in this remix

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

    static func == (lhs: RemixTreeNode, rhs: RemixTreeNode) -> Bool {
        lhs.currNodeID == rhs.currNodeID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(currNodeID)
    }
}
// End of Eesh New Edit

// Eesh New Edit: Updated RemixTree to work with ID-based RemixTreeNode
// remix tree itself
class RemixTree {

    var rootNode: RemixTreeNode?

    init(nodeID: String, parentNodeID: String, rootNodeOfTreeID: String, childrenIDs: [String], descriptionOfRecipeChanges: String = "") {

        self.rootNode = RemixTreeNode(currNodeID: nodeID,
                                      parentNodeID: "none",
                                      rootNodeOfTreeID: rootNodeOfTreeID,
                                      childrenIDs: childrenIDs,
                                      descriptionOfRecipeChanges: descriptionOfRecipeChanges)
    }
// End of Eesh New Edit
    
    // Eesh New Edit: Removed old object-reference-based deleteNode method
    // deleteNode has been removed - use deleteNodeFirebase for ID-based deletion
    // End of Eesh New Edit

    /**
            Handles node deletion in firebase
     */
    // Eesh New Edit: Updated to use realRemixTreeNodes collection
    func deleteNodeFirebase(nodeId: String) {
        let nodeRef = Firebase.db.collection("realRemixTreeNodes").document(nodeId)
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
                        let parentRef = Firebase.db.collection("realRemixTreeNodes").document(parent)

                        for childID in children {
                            let childRef = Firebase.db.collection("realRemixTreeNodes").document(childID)
                            childRef.updateData([
                                "parentID": parent
                            ])

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
    
    // Eesh New Edit: Removed addNode and findNode - incompatible with ID-based structure
    // These methods relied on object references and are no longer needed.
    // Use RemixData.shared.nodes to access all nodes and filter by ID.
    // End of Eesh New Edit
}
