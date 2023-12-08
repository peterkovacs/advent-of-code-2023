
import ArgumentParser
import Parsing
import Foundation
import Collections

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

  func part2(_ stdin: String) throws {
    let (instructions, nodes) = try Parser.parser.parse(stdin)
    let starting = nodes.keys.filter { $0.last == "A" }
    struct Visit: Hashable {
      let node: String
      let i: Int
    }

    let cycles = starting.map {
      var node = $0
      var next = Array(instructions.enumerated()).cycled().makeIterator()
      var visited = Set<Visit>()
      var i = next.next()!
      var count = 0

      while visited.insert(.init(node: node, i: i.offset)).inserted, node.last != "Z" {
        node = nodes[node]![keyPath: i.element]
        i = next.next()!
        count += 1
      }

      print($0, node, count)

      return count
    }

    print(cycles)
  }

  func run() throws {
    let stdin = self.stdin
    try part1(stdin)
    try part2(stdin)
  }
}

