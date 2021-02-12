//
//  FastDiffDiffAllLevelTests.swift
//  FastDiffTests
//
//  Created by Vijaya Prakash Kandel on 12.02.21.
//

import XCTest
@testable import FastDiff
import Randomizer

extension FastDiffTests {
    
    func test_whenDiffingAllLevelsForFlatItems_diffResultEqualsToAllDiff() {
        let old = [1,2,3]
        let new = [1,2,4]
        let diffNormal = diff(old, new)
        let diffAllLevels = diffAllLevel(old, new)
        XCTAssertEqual(diffNormal, diffAllLevels)
    }
    
    func test_whenNestedItemIsProvided_thenDiffAllLevelsWillIdentifyNestedChanges() {
        let nodeA = Node(name: .random, metadata: .random, edges: [
            Node(name: .random, metadata: .random, edges: [])
        ])
        
        let nodeB = Node(name: nodeA.name, metadata: nodeA.metadata, edges: [
            nodeA.edges.first!,
            Node(name: .random, metadata: .random, edges: [])
        ])
        
        let diffSingleLevel = diff([nodeA], [nodeB])
        let diffAll = diffAllLevel([nodeA], [nodeB])
        
        XCTAssertEqual(diffSingleLevel.count, 1)
        guard case .update(_,_,_) = diffSingleLevel.first else {
            XCTFail("Since the name and meta on the parent level are same; its a container update")
            return
        }
        
        XCTAssertEqual(diffAll.count, 1)
        guard case let .add(item, index) = diffAll.first! else {
            XCTFail("Should be Add at second position on children items. Nothing else changed")
            return
        }
        XCTAssertEqual(index, 1)
        XCTAssertEqual(item.name, nodeB.edges.last!.name)
        XCTAssertEqual(item.metadata, nodeB.edges.last!.metadata)
    }
    
    func test_when3LevelDownTreeIsDiffedOnAllLevel_thenItWorks() {
        let nodeA = Node(name: .random, metadata: .random, edges: [
            Node(name: .random, metadata: .random, edges: [
                Node(name: .random, metadata: .random, edges: [])
            ])
        ])
        
        let nodeB = Node(name: nodeA.name, metadata: nodeA.metadata, edges: [
            Node(name: nodeA.edges.first!.name, metadata: nodeA.edges.first!.metadata, edges: [
                Node(name: nodeA.edges.first!.edges.first!.name, metadata: nodeA.edges.first!.edges.first!.metadata, edges: []),
                Node(name: .random, metadata: .random, edges: [])       // new item
            ])
        ])
        
        let diffSingleLevel = diff([nodeA], [nodeB])
        let diffAll = diffAllLevel([nodeA], [nodeB])
        
        XCTAssertEqual(diffSingleLevel.count, 1)
        guard case .update(_,_,_) = diffSingleLevel.first else {
            XCTFail("Since the name and meta on the parent level are same; its a container update")
            return
        }
        
        XCTAssertEqual(diffAll.count, 1)
        guard case let .add(item, index) = diffAll.first! else {
            XCTFail("Should be Add at second position on children items. Nothing else changed")
            return
        }
        XCTAssertEqual(index, 1)
        XCTAssertEqual(item.name, nodeB.edges.first!.edges.last!.name)
        XCTAssertEqual(item.metadata, nodeB.edges.first!.edges.last!.metadata)
    }
    
}

struct Node {
    let name: String
    let metadata: Int
    let edges: [Node]
}

extension Node: Diffable {
    
    var innerDiffableItems: [Node] {
        return edges
    }
    
    var diffHash: Int {
        name.hashValue ^ metadata.hashValue
    }
}

