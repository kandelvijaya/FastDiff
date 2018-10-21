<div align="center">
  <img src="logo.png"><br><br>
</div>

-----------------

# Fast Diff ![CI status](https://img.shields.io/badge/build-passing-brightgreen.svg)

General purpose, fast diff algorithm supporting [m] level nested diffs. 

## Time Complexity
- Linear [O(n)]

## Why?
1. Faster than the mainstream algorithm. Most diffing algorithm are O(nlogn) or O(n.m). This one is linear (O(n)).
2. Most algorithm solve Least Common Subsequence problem which has hard to grasp implementation. This uses 6 simple looping passes.
3. Supports nested diffing (if you desire)

## Installation
### Via cocoapods
```swift
pod 'FastDiff'
```
And then in the terminal `pod update`. If you are new to cocoapods please check out [Cocoapods Installation](https://guides.cocoapods.org/using/using-cocoapods)

### Via Swift Package Manager
Declare the dependency in the swift `Package.swift` file like such:
```swift
dependencies: [
  ///.... other deps
  .package(url: "https://www.github.com/kandelvijaya/FastDiff", from: "1.0.0"),
]
```

Execute the update command `swift package update` and then `swift package generate-xcodeproj`.

## Running the tests

Go to the source directory, and run:
```swift
$ swift test
```

## Usage
### Algorithm & Verification
```swift
let oldModels = ["apple", "microsoft"]
let newModels = ["apple", "microsoft", "tesla"]


/// Algorithm
let changeSet = diff(oldModels, newModels)
// [.addition("tesla", at: 2)]


/// Verification
oldModels.merged(with: changeSet) == newModels 
// true
```

<div align="center">
  <img src="./Documentation/diffConcept1.png"><br><br>
</div>


Note that `diff` produces changeset that can't be merged into old collections as is, most of the times. 
The changeset has to be `ordered` in-order for successful merge. This is also useful if you want to
apply changeset to `UITableView` or `UICollectionView`.

```swift
let chnageSet = diff(["A","B"], [“C”,"D"])
// [.delete("A",0), .delete("B",1), .add("C",0), .add(“D",1)]

let orderedChangeSet = orderedOperation(from: changeSet)
// [.delete("b",1), .delete("a",0), .add("c",0), .add("d",1)]

```

### Concept and advanced usage in List View Controller (iOS)
Please check out this presentation slides that I gave at [@mobiconf 2018](https://drive.google.com/file/d/1eY0k_5sHBDgK6Qx6-VR3HTmCQEi9qaW3/view?usp=sharing)

## Contributing

Feel free to contribute with Pull Requests. Should you require more feature, find a bug or want to propose new idea; feel free to post a issue. 

### Potential Tasks
- Check the issues section for helpful tasks and more description. This is a good place to start contributing. 

## Authors

1. @kandelvijaya (https://twitter.com/kandelvijaya)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Inspired by Paul Heckel's paper & algorithm 
