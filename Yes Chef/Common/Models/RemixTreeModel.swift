//
//  RemixTreeModel.swift
//  Yes Chef
//
//  Created by Nitya Potti on 9/25/25.
//

import Foundation
class RemixTreeNode  {
    
    let currNodeID: String
    let parentNodeID: String?
    let rootNodeOfTreeID: String
    
    var childrenIDs: [String]
    
    var descriptionOfRecipeChanges: String
    
    init(currNodeID: String,
         parentNodeID: String?,
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

class RemixTreeModel {
    
}
