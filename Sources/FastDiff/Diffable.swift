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
    
    
    
    /**
     **Defaults** to return empty array; making it non-container type.
     Allows Diffable to represent a Graph/Tree structure.
     
     Items can be in update state either object pointed by pointer changed or their internalItems aren't the same.
     
     ## Note
     Equality and hashValue stay as is
     
     ## Cases
     2 Diffable items determined to be in **update** state if
     - both items are not leaves (non-container type) in the graph
     - are not equal (Equality considers every property in Diffable)
     - both have the same diffHash (diffHash should exclude innerDiffableItems)
     */
    var innerDiffableItems: [InternalItemType] { get }
    
    /**
     **Deafults** to returning `hashValue` when this type conforms to `Equatable`
     
      Only conform and customize conformance if you intend to represnet this Diffable type as Graph/Tree.
      When you conform; leave out `innerDiffableItems`s hashValue.
     
      ## Two Diffable tiems
      - with same diffHash
           - and not equal is considered update
           - and equal is considered exact replicated item.
      - with different diffHash
           - cannot be equal (impossible)
           - are considered 2 different items (delete then insert)
     */
    var diffHash: Int { get }
    
}


extension Diffable {
    
    public var diffHash: Int { return self.hashValue }
    public var innerDiffableItems: [InternalItemType] { return [] }
    
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

