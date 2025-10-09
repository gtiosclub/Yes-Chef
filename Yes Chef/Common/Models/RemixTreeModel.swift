//
//  RemixTreeModel.swift
//  Yes Chef
//
//  Created by Nitya Potti on 9/25/25.
//

import Foundation
import Firebase
//node in the remix tree
class RemixTreeNode  {
    
    let currNodeID: String
    var parentNode: RemixTreeNode?
    let rootNodeOfTree: RemixTreeNode
    
    var children: [RemixTreeNode]
    
    var descriptionOfRecipeChanges: String
    
    init(currNodeID: String,
         parentNode: RemixTreeNode?,
         rootNodeOfTree: RemixTreeNode,
         children: [RemixTreeNode],
         descriptionOfRecipeChanges: String = "") {
        
        self.currNodeID = currNodeID
        self.parentNode = parentNode
        self.rootNodeOfTree = rootNodeOfTree
        self.children = children
        self.descriptionOfRecipeChanges = descriptionOfRecipeChanges
    }
}

// remix tree itself
class RemixTree {
    
    let rootNode: RemixTreeNode
    
    init(nodeID: String, parentNode: RemixTreeNode?, rootNodeOfTree: RemixTreeNode, children: [RemixTreeNode], descriptionOfRecipeChanges: String = "") {
        
        self.rootNode = RemixTreeNode(currNodeID: nodeID,
                                          parentNode: nil,
                                          rootNodeOfTree: rootNodeOfTree,
                                          children: children)
    }
    
    /**
    Should delete a node from the remix tree. If a node is deleted and it has children, the parent of the children get reassigned to the parent of the deleted node.
     */
    func deleteNode(node: RemixTreeNode) {
        guard let parent = node.parentNode else {
            print("Cannot delete root node")
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
    
    /**
            Handles node deletion in firebase
     */
    func deleteNodeFirebase(nodeId: String) {
        let nodeRef = Firebase.db.collection("remixTreeNode").document(nodeId)
        
        nodeRef.getDocument { (document, error) in
            if let error = error {
                print("Error checking document: \(error.localizedDescription)")
                return
            }
            
            if let node = document, node.exists {
                
                if let children = node.get("childrenID") as? [String] {
                    //asumes children are valid
                    if let parent = node.get("parentID") as? String {
                        let parentRef = Firebase.db.collection("remixTreeNode").document(parent)
                        
                        for childID in children {
                            let childRef = Firebase.db.collection("remixTreeNode").document(childID)
                            childRef.updateData([
                                "parentID": parent
                            ])
                           
                        }
                        
                        parentRef.updateData([
                            "childrenID": FieldValue.arrayUnion(children)
                        ])
                        
                        parentRef.updateData([
                            "childrenID": FieldValue.arrayRemove([nodeId])
                        ])
                        
                        nodeRef.delete()
                    } else {
                        print("'parentID' field is missing or not an array of strings")
                    }
                    
                } else {
                    print("'childrenID' field is missing or not an array of strings")
                }
                

            } else {
                print("Document does not exist — nothing to delete.")
            }
        }
    }
    
    func addNode(nodeID: String, parentNode: RemixTreeNode?, rootNodeOfTree: RemixTreeNode, children: [RemixTreeNode], descriptionOfRecipeChanges: String = "") {
        
        let newNode = RemixTreeNode(currNodeID: nodeID,
                                    parentNode: parentNode,
                                    rootNodeOfTree: rootNodeOfTree,
                                    children: children,
                                    descriptionOfRecipeChanges: descriptionOfRecipeChanges)
        parentNode?.children.append(newNode)
    }
    
    func findNode(nodeID: String) -> RemixTreeNode? {
        
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
}
