//
//  RemixTreeModel.swift
//  Yes Chef
//
//  Created by Nitya Potti on 9/25/25.
//

import Foundation
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
    
    init(rootNode: RemixTreeNode) {
        self.rootNode = rootNode
    }
    
    /**
    Should delete a node from the remix tree. If a node is deleted and it has children, the parent of the children get reassigned to the parent of the deleted node.
     */
    func deleteNode(node: RemixTreeNode) {
        
        
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
