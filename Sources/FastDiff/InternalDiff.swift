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
            let oldChildItems = oldContainer.children
            let newChildItems = newContainer.children
            let internalDiff = orderedOperation(from: diff(oldChildItems, newChildItems))
            let output = (atIndex, internalDiff)
            accumulator.append(output)
        default:
            break
        }
    }
    return accumulator
}
