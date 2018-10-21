//
//  FastDiffComplexityTests.swift
//  FastDiff
//
//  Created by Vijaya Prakash Kandel on 21.10.18.
//

import Foundation
import XCTest
import AlgoChecker
@testable import FastDiff

final class FastDiffComplexityTests: XCTestCase {

    func test_fastDiff_hasLinearTimeComplexity() {
        // 1. Wrap Algorithm in Operation
        let algoOperation = AlgorithmChecker.Operation<Int> { (inputProvider, completion) in
            let input1: [Int] = inputProvider.input()
            let input2: [Int] = inputProvider.input()
            let result = diff(input1, input2)
            completion(result.count)
        }

        // 3. Find/assert algorithm complexity
        var checker = AlgorithmChecker()
        let result = checker.assert(algorithm: algoOperation, has: .linear, tolerance: .low)

        XCTAssertEqual(result, true)
    }

}
