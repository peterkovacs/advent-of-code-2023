// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import Utility

extension ParsableCommand {
  var input: AnyIterator<String> {
    .init { readLine(strippingNewline: true) }
  }

  var stdin: String {
    String(data: FileHandle.standardInput.readDataToEndOfFile(), encoding: .utf8) ?? "invalid utf-8 input"
  }

  var grid: Grid<Character> {
    let input = Array(input)
    return Grid(input.joined(), size: .init(x: input[0].count, y: input.count))
  }

  func infiniteGrid(_ default: Character) -> InfiniteGrid<Character> {
    let lines = Array(input)
    let joined = lines.joined()
    let size = Coord(x: lines[0].count, y: lines.count)
    assert(size.x * size.y == joined.count, "Input provided was not the expected size: \(size): \(size.x * size.y) != \(joined.count)")

    return InfiniteGrid(
      joined,
      size: size,
      default: `default`
    )
  }

}

@main
public struct AdventOfCode: ParsableCommand {
  public static var configuration: CommandConfiguration = .init(
    abstract: "AdventOfCode 2023",
    subcommands: [
      Day1.self,  Day2.self,  Day3.self,  Day4.self,  Day5.self,  Day6.self,  Day7.self,  Day8.self,  Day9.self,  Day10.self,
      Day11.self, Day12.self, Day13.self, Day14.self, Day15.self, Day16.self, Day17.self, Day18.self, Day19.self, Day20.self,
      Day21.self, Day22.self, Day23.self, Day24.self, Day25.self
    ]
  )

  public init() { }
}
