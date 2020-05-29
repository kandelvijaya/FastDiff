//
//  Diff+UIKit.swift
//  AlgoChecker
//
//  Created by Vijaya Prakash Kandel on 08.01.20.
//

import Foundation

/**
 These below functions support the use of Diff naturally to UITableView or UICollectionView.
 */

internal func packingConsequetiveDeleteAddWithUpdate<T>(from diffResult:  [DiffOperation<T>.Simple]) -> [DiffOperation<T>.Simple] {
    if diffResult.isEmpty { return [] }
    
    var currentSeekIndex = 0 // This is the index that is not processed.
    
    var accumulator: [DiffOperation<T>.Simple] = []
    while currentSeekIndex < diffResult.count {
        let thisItem = diffResult[currentSeekIndex]
        let nextIndex = currentSeekIndex.advanced(by: 1)
        
        if nextIndex < diffResult.count {
            let nextItem = diffResult[nextIndex]
            switch (thisItem, nextItem) {
            case let (.delete(di, dIndex), .add(ai, aIndex)) where dIndex == aIndex:
                let update = DiffOperation<T>.Simple.update(di, ai, dIndex)
                accumulator.append(update)
            default:
                accumulator.append(thisItem)
                accumulator.append(nextItem)
            }
            currentSeekIndex = nextIndex.advanced(by: 1)
        } else {
            // This is the last item
            accumulator.append(thisItem)
            // This breaks the iteration
            currentSeekIndex = nextIndex
        }
    }
    return accumulator
}


/**
 Entire Tree/Graph diffing is possible.
 However not something the library encourages due to added complexity O(n^2).
 If you so choose to diff then please use this function.
 */
public func diffAllLevel<T>(_ oldContent: [T], _ newContent: [T]) -> [DiffOperation<T>] where T: Diffable, T.InternalItemType == T {
    if oldContent.isEmpty && newContent.isEmpty { return [] }
    var accumulator: [DiffOperation<T>] = []
    let thisLevelDiff = diff(oldContent, newContent)
    for index in thisLevelDiff {
        if case let .update(o, n, _) = index {
            accumulator = accumulator + diffAllLevel(o.children, n.children)
        } else {
            accumulator.append(index)
        }
    }
    return accumulator
}


/**
 Orders diff operation in way UIKit can process as is. Only orderedDiffOperations can be applied back to old items for merge.
 
 This is a helper function which assumes that
 1. Deletion happens first from end index on original [T]
 2. Insertions follows
 3. Update Follows
 
 - Note: This is the case with UIKit (UITableView and UICollectionView dataSources)
 
 - Limitation: Can't extend a protocol with a generic typed enum (generic type in general)
 extension Array where Element: Operation<T> { }
 */
public func orderedOperation<T>(from operations: [DiffOperation<T>]) -> [DiffOperation<T>.Simple] {
    /// Deletions need to happen from higher index to lower (to avoid corrupted indexes)
    ///  [x, y, z] will be corrupt if we attempt [d(0), d(2), d(1)]
    ///  d(0) succeeds then array is [x,y]. Attempting to delete at index 2 produces out of bounds error.
    /// Therefore we sort in descending order of index
    var deletions = [Int: DiffOperation<T>.Simple]()
    var insertions = [DiffOperation<T>.Simple]()
    var updates = [DiffOperation<T>.Simple]()

    for oper in operations {
        switch oper {
        case let .update(item, newItem, index):
            updates.append(.update(item, newItem, index))
        case let .add(item, atIndex):
            insertions.append(.add(item, atIndex))
        case let .delete(item, from):
            deletions[from] = .delete(item, from)
        case let .move(item, from, to):
            insertions.append(.add(item, to))
            deletions[from] = .delete(item, from)
        }
    }
    let descendingOrderedIndexDeletions = deletions.sorted(by: {$0.0 > $1.0 }).map{ $0.1 }
    return descendingOrderedIndexDeletions + insertions + updates
}


/**
 Optimizes the diff for easy usage for UIKit List (UITableView / UICollectionView) Datasources integration.
 
 This takes care of:
 - emitting ordered operations (needed to merge. This is what iOS datasources expect.)
 - emitting optimized operation: consequetive add and delete on same index is replaced by update.
 */
public func diffOptimizingForUIKitUsage<T>(_ old: [T], new: [T]) -> [DiffOperation<T>.Simple] where T: Diffable {
    return packingConsequetiveDeleteAddWithUpdate(from: orderedOperation(from: diff(old, new)))
}
