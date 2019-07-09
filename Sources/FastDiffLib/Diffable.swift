//
//  Diffable.swift
//  FastDiff
//
//  Created by Vijaya Prakash Kandel on 18.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

/// Conforming types can be used to calculate `diff`
public protocol Diffable: Hashable {

    /// Used to represent the internalItemType that represents another level.
    /// By default, this will be the same type as the conforming i.e. without customization.
    associatedtype InternalItemType: Diffable = Self

    /// Internal Items whose `diff` should be considered in case of `update`
    /// Typical usage would be to override this and return a set of items.
    /// Those items should be considered both for equality and hashValue as normal.
    /// Parent/Container are determined to be in `update` state, if either object
    /// pointed by pointer changed or their internalItems aren't the same.
    var children: [InternalItemType] { get }

    /// Make sure to do 2 things:
    /// 1. Provide a very unique hash value. If hash collision occurs,
    ///    diff result will be false positive.
    /// 2. If this is a parent container then exclude hash computation
    ///    for the children Diffable. Two equal container models with same hash
    ///    are checked for equality to determine either they are uniquely same
    ///    or update.
    /// This is defaulted to `hashValue` when conforming type conforms to Equatable
    var diffHash: Int { get }

}


extension Diffable {

    public var diffHash: Int { return self.hashValue }
    public var children: [InternalItemType] { return [] }

}


extension Array: Diffable where Element: Diffable {

    public var diffHash: Int {
        return reduce(0) { $0 ^ $1.diffHash }
    }

} 

extension String: Diffable {}
extension Int: Diffable {}
extension Character: Diffable {}
extension UInt: Diffable {}
extension URL: Diffable {}
extension Substring: Diffable {}
extension Double: Diffable {}
extension Float: Diffable {}
extension Bool: Diffable {}

