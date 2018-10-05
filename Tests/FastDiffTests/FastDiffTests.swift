import XCTest
@testable import FastDiff

struct Cat: Hashable, Diffable {
    let name: String
}

struct Person {
    let name: String
    let age: Int
    let pets: [Cat]
}


extension Person: Hashable, Diffable {

    typealias InternalItemType = Cat

    var diffHash: Int {
        return name.hashValue ^ age.hashValue
    }

    var children: [Person.InternalItemType] {
        return pets
    }
}

final class FastDiffTests: XCTestCase {

    func test_whenEmptyIntArrayIsDiffedWithSingleElementArray_thenThereIs1Insertion() {
        let opers = diff([Int](), [1])
        XCTAssertEqual(opers.count, 1)
        XCTAssertEqual(opers[0], .add(1,0))
    }

    func test_whenNewArrayIsEmpty_thenEverythingIsDeleted() {
        let opers = diff([1],[])
        XCTAssertEqual(opers.count, 1)
        XCTAssertEqual(opers[0], .delete(1,0))
    }

    func test_whenBothEmptyArrayAreDiffed_thenOperationsIsEmpty() {
        XCTAssertEqual(diff([Int](),[]), [])
    }

    func test_whenSingletonArray_whereSameItemIsChnaged_thenItIsUpdate() {
        XCTAssertEqual(diff([1], [2]), [.delete(1,0), .add(2,0)])
    }

    func test_seemsLikeMove() {
        let opers = diff([1,2,3], [2,3])
        XCTAssertEqual(opers.count, 1)
        XCTAssertEqual(opers, [.delete(1,0)])
    }

    func test_seemsLikeMoveRight() {
        let opers = diff([1,2], [4,1,2])
        XCTAssertEqual(opers.count, 1)
        XCTAssertEqual(opers, [.add(4,0)])
    }

    func test_moveCrissCross() {
        let opers = diff([1,2], [2,1])
        XCTAssertEqual(opers.count, 2)
        XCTAssertEqual(opers, [.move(2,1,0), .move(1,0,1)])
    }

    func test_whenContainerTypesAreDiffed_thenItProducesUpdate() {
        let operation = diff([x], [y])
        XCTAssertEqual(operation.first!, .update(x, y, 0))
    }

    func test_whenContainerTypesAreDiffed_thereIsUpdateAndEachContainsCollectionOfDiffable_thenInternalDiffCanBePerformed() {
        let operation = diff([x], [y])
        XCTAssertEqual(operation.first!, .update(x, y, 0))
        let internalDiff = diff(x.children, y.children)
        XCTAssertEqual(internalDiff.count, 1)
        XCTAssertEqual(internalDiff.first!, .add(Cat(name: "meow jr."), 1))
    }

    let x = Person(name: "BJ", age: -1, pets: [Cat(name: "meow")])
    let y = Person(name: "BJ", age: -1, pets: [Cat(name: "meow"),
                                               Cat(name: "meow jr.")])

    static var allTests = [
        ("test move", test_seemsLikeMove),
        ("test crisscross", test_moveCrissCross),
        ("test move right", test_seemsLikeMoveRight),
        // TODO:- include more tests
    ]
    
}
