
import ArgumentParser
import Parsing
import Foundation
import Utility
import Algorithms

struct Day8: ParsableCommand { 
  enum Parser {
    typealias Node = (String, String)
    static let instructions = Many {
      OneOf {
        "L".map { \Node.0 }
        "R".map { \Node.1 }
      }
    } terminator: {
      Whitespace(2, .vertical)
    }.eraseToAnyParser()

    static let nodes = Many (into: [:]) { (result: inout [String: (String, String)], element: (String, String, String)) in
      result[element.0] = (element.1, element.2)
    } element: {
      Prefix<Substring>(3).map(.string)
      " = ("
      Prefix(3).map(.string)
      ", "
      Prefix(3).map(.string)
      ")"
    } separator: {
      Whitespace(.vertical)
    } terminator: {
      Whitespace(0...1, .vertical)
      End()
    }

    static let parser = Parse {
      instructions
      nodes
    }
  }

  func part1(_ stdin: String) throws {
    let (instructions, nodes) = try Parser.parser.parse(stdin)
    var node = "AAA"
    var j = instructions.cycled().makeIterator()
    var count = 0
    while node != "ZZZ" {
      node = nodes[node]![keyPath: j.next()!]
      count += 1
    }

    print("Part 1", count)
  }

  struct Iterator: Sequence, IteratorProtocol {
    var node: String
    var iter: CycledSequence<[WritableKeyPath<Day8.Parser.Node, String>]>.Iterator
    let nodes: [String: (String, String)]

    mutating func next() -> String? {
      if node.last == "Z" { return nil }
      defer { self.node = nodes[node]![keyPath: iter.next()!] }
      return node
    }
  }

  func part2(_ stdin: String) throws {
    let (instructions, nodes) = try Parser.parser.parse(stdin)
    let starting = nodes.keys.filter { $0.last == "A" }

    let part2 = starting.map {
      Iterator(
        node: $0,
        iter: instructions.cycled().makeIterator(),
        nodes: nodes
      ).reduce(0) { i, _ in i + 1 }
    }.reduce(1, lcm)

    print("Part 2", part2)
  }

  func run() throws {
    let stdin = self.stdin
    try part1(stdin)
    try part2(stdin)
  }
}
