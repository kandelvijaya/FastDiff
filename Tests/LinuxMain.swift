import XCTest

import FastDiffTests

var tests = [XCTestCaseEntry]()
tests += FastDiffTests.allTests()
XCTMain(tests)