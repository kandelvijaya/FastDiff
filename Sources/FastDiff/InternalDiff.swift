//
//  InternalDiff.swift
//  FastDiff
//
//  Created by Vijaya Prakash Kandel on 25.09.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

public func internalDiff<T: Diffable>(from diffOperations: [DiffOperation<T>.Simple]) -> [(offset: Int, operations: [DiffOperation<T.InternalItemType>.Simple])] {
    var accumulator = [(offset: Int, operations: [DiffOperation<T.InternalItemType>.Simple])]()
    for operation in diffOperations {
        switch operation {
        case let .update(oldContainer, newContainer, atIndex):
            let oldChildItems = oldContainer.innerDiffableItems
            let newChildItems = newContainer.innerDiffableItems
            let internalDiff = orderedOperation(from: diff(oldChildItems, newChildItems))
            let output = (atIndex, internalDiff)
            accumulator.append(output)
        default:
            break
        }
    }
    return accumulator
}


/// Calculates diff from entire graph going deeper as it finds `update` on container.
/// It is greedy algorithm.
/// - NOTE: Profile when running on main thread.
///
/// - Complexity:- O(allEdges * nlog(n))
public func diffAllLevel<T>(_ oldContent: [T], _ newContent: [T]) -> [DiffOperation<T>] where T: Diffable, T.InternalItemType == T {
    if oldContent.isEmpty && newContent.isEmpty { return [] }
    var accumulator: [DiffOperation<T>] = []
    
    let thisLevelDiff = diff(oldContent, newContent)
    for oneDiffItem in thisLevelDiff {
        // We ignore the index.
        if case let .update(old, new, _) = oneDiffItem {
            accumulator = accumulator + diffAllLevel(old.innerDiffableItems, new.innerDiffableItems)
        } else {
            accumulator.append(oneDiffItem)
        }
    }
    return accumulator
}
