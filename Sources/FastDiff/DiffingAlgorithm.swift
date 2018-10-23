//
//  Diff.swift
//  FastDiff
//
//  Created by Vijaya Prakash Kandel on 18.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

/// During the diff, we are mostly interested in this combination
/// 1. one - one
/// 2. one/many - one/many
/// `zero` is the base or non-existing line count
enum OccuranceCount {

    case zero, one, many

    func increment() -> OccuranceCount {
        switch self {
        case .zero:
            return .one
        case .one, .many:
            return .many
        }
    }

}

/// SymEntry is modelled as reference type, so that we can keep
/// a pointer NOT either a entire copy (value type) or
/// unsafe raw pointer which requires manual pointer dance.
class SymEntry {

    /// Occurance in old file
    var oc: OccuranceCount = .zero

    /// Occurance in new file
    var nc: OccuranceCount = .zero

    /// Line number in old set
    /// This only makes sense if OC == NC == .one
    var olno: Int = -1

    /// Detects if line is identically unique across both changes
    func isIdenticallyUnqiueAcrossChanges() -> Bool {
        return oc == nc && nc == .one
    }

}


/// Represents either a SymEntry (pointer by class) or
/// LineNumber in another change set if the changes were resolved
enum LineLookup {
    /// SymEntry should be a reference/pointer for efficiency
    case sym(SymEntry)
    case lineNumber(Int)

    func pointsToSameSymEntry(as anotherLookup: LineLookup) -> Bool {
        if case let (.sym(s1), .sym(s2)) = (self, anotherLookup) {
            /// pointer check
            return s1 === s2
        }
        return false
    }

}


/// Kinds of operation
public enum DiffOperation<T> {
    case add(T, Int)
    case delete(T, Int)
    case move(T, Int, Int)
    case update(T,T,Int)

    public enum Simple {
        case add(T,Int)
        case delete(T, Int)
        case update(T,T,Int)
    }

}

extension DiffOperation: Equatable where T: Equatable { }

// MARK:- Playground view

extension DiffOperation: CustomStringConvertible {

    public var description: String {
        switch self {
        case let .add(v, i):
            return "A(\(v)@\(i))"
        case let .delete(v, i):
            return "D(\(v)@\(i))"
        case let .move(v,i,j):
            return "M(\(v)from\(i)->\(j))"
        case let .update(v1, v2, i):
            return "U(\(v1)=>\(v2)@\(i))"
        }
    }

}


extension SymEntry: CustomStringConvertible {
    var description: String {
        return "{oc: \(oc), nc: \(nc), olno: \(olno)}"
    }
}


extension LineLookup: CustomStringConvertible {
    var description: String {
        switch self {
        case let .lineNumber(l):
            return "L(\(l))"
        case let .sym(e):
            return "S(\(e))"
        }
    }
}



public func diff<T>(_ oldContent: [T], _ newContent: [T]) -> [DiffOperation<T>] where T: Diffable {

    // Treats the same/equal/identical collections unchanged to not be used for diffing
    // diff([1,1], [1,1]) ==> no change
    if oldContent.hashValue == newContent.hashValue && oldContent.diffHash == newContent.diffHash && oldContent == newContent { return [] }
    if oldContent.isEmpty && newContent.isEmpty { return [] }

    typealias DiffHash = Int

    var symTable: [DiffHash: SymEntry] = [:]

    //1. go over new and create table
    //2. go over old and create/edit table
    //3. go over new, lookup table and detect unique occurance
    //4. go over new, check block of changes in ascending order
    //5. go over new, check block of changes in descending order
    //6. go over old and get deletions + go over new and
    //   find insertion & deletion

    /// LineLookup map for each index in old content
    /// for index `i` in old content, acess LineLookup with `oas[i]`
    var oas: [LineLookup] = []

    /// LineLookup map for each index in new content
    /// for index `i` in new content, acess LineLookup with `nas[i]`
    var nas: [LineLookup] = []


    /// Pass1
    /// Iterate over new content and build both `symEntry`s and `nas`
    for content in newContent {
        let entry = symTable[content.diffHash] ?? SymEntry()
        entry.nc = entry.nc.increment()
        symTable[content.diffHash] = entry
        nas.append(LineLookup.sym(entry))
    }


    /// Pass2
    /// Iterate over old content and do the same as pass1
    for (index, content) in oldContent.enumerated() {
        let entry = symTable[content.diffHash] ?? SymEntry()
        entry.oc = entry.oc.increment()
        entry.olno = index
        symTable[content.diffHash] = entry
        oas.append(LineLookup.sym(entry))
    }


    /// Pass 3
    /// Detect unique line pair across both new and old content
    /// if OC == NC == .one, then for nas[i] substitute olno from its sym Emtry
    for (index, lookup) in nas.enumerated() {
        if case let .sym(entry) = lookup, entry.isIdenticallyUnqiueAcrossChanges() {
            nas[index] = .lineNumber(entry.olno)
            oas[entry.olno] = .lineNumber(index)
        }
    }


    /// Pass 4
    /// Check if line/s adjecent to unique identical pairs are the same.
    /// This is to detect a block of changes. The detection moves from top to bottom.
    /// i.e consider one/many pairs adjecent to found pair.
    for (index, lookup) in nas.enumerated() {
        if case let .lineNumber(oldLine) = lookup {
            let incrIndex = index + 1
            let incrOldLine = oldLine + 1
            if incrIndex < nas.count, incrOldLine < oas.count, oas[incrOldLine].pointsToSameSymEntry(as: nas[incrIndex]) {
                nas[incrIndex] = .lineNumber(incrOldLine)
                oas[incrOldLine] = .lineNumber(incrIndex)
            }
        }
    }

    /// Pass 5
    /// Same as pass 4 but looks before the unique identical pair
    /// to find blocks.
    for (index, lookup) in nas.enumerated().reversed() {
        if case let .lineNumber(oldLine) = lookup {
            let decrIndex = index - 1
            let decrOldLine = oldLine - 1
            if decrIndex >= 0, decrOldLine >= 0, oas[decrOldLine].pointsToSameSymEntry(as: nas[decrIndex]) {
                nas[decrIndex] = .lineNumber(decrOldLine)
                oas[decrOldLine] = .lineNumber(decrIndex)
            }
        }
    }

    /// Pass 6
    /// Go through oas and nas and collect change set
    ///      old: a b c d
    ///      new: e a b d f
    ///   change: [insert e at 0, insert f at 4]  [delete c from 2]
    var operations = [DiffOperation<T>]()
    var deletionKeeper = [Int: Int]() // lineNum: how many lines deleted prior to this
    var runningOffset = 0
    for (index, item) in oas.enumerated() {
        if case .sym(_) = item {
            operations.append(.delete(oldContent[index], index))
            runningOffset += 1
        }
        deletionKeeper[index] = runningOffset
    }

    runningOffset = 0
    for (index, item) in nas.enumerated() {
        switch item {
        case .sym(_):
            operations.append(.add(newContent[index], index))
            runningOffset += 1
        case let .lineNumber(oldLineNumber):
            /// Maybe the object hash is the same but the equality is not
            /// good point for getting internal diff
            if newContent[index] != oldContent[oldLineNumber] {
                operations.append(.update(oldContent[oldLineNumber], newContent[index], index))
            }
            let deleteOffSetToNegect = deletionKeeper[oldLineNumber] ?? 0
            let calculatedIndexAfterPreviousInsertionAndDeletionCounts = oldLineNumber - deleteOffSetToNegect + runningOffset
            if calculatedIndexAfterPreviousInsertionAndDeletionCounts != index {
                operations.append(.move(newContent[index], oldLineNumber, index))
            }
        }
    }

    return operations
}

/** Limitation: Can't extend a protocol with a generic typed enum (generic type in general)
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


extension Array where Element: Hashable {

    public func merged(with operations: [DiffOperation<Element>]) -> Array {
        let orderedOperations = orderedOperation(from: operations)
        return self.merged(with: orderedOperations)
    }

    public func merged(with operations: [DiffOperation<Element>.Simple]) -> Array {
        /// might not work on collection as we need to initialize a concrete type
        var mutableCollection: [Element] = self
        for operation in operations {
            switch operation {
            case let .add(item, addAt):
                mutableCollection.insert(item, at: addAt)
            case let .update(oldItem, newItem, updateAt):
                assert(mutableCollection[updateAt] == oldItem, "update doesnot have proper old value")
                mutableCollection[updateAt] = newItem
            case let .delete(_, atIndex):
                mutableCollection.remove(at: atIndex)
            }
        }
        return mutableCollection
    }

}
