
import ArgumentParser
import Parsing
import Algorithms

struct Day9: ParsableCommand { 
  mutating func run() throws {
    let numbers = try input.map { try Many { Int.parser() } separator: { Whitespace() }  terminator: { End() }.parse($0) }
    let part1 = numbers.map { $0.nextNumber() }.reduce(0, +)
    print("Part 1", part1)
    let part2 = numbers.map { $0.prevNumber() }.reduce(0, +)
    print("Part 1", part2)
  }
}

private extension Array where Element == Int {
  func nextNumber() -> Int {
    let difference = difference()

    if difference.allSatisfy({ $0 == 0 }) {
      return last!
    } else {
      return last! + difference.nextNumber()
    }
  }

  func prevNumber() -> Int {
    let difference = difference()

    if difference.allSatisfy({ $0 == 0 }) {
      return first!
    } else {
      return first! - difference.prevNumber()
    }
  }


  func difference() -> Self {
    adjacentPairs().map { $0.1 - $0.0 }
  }
}
