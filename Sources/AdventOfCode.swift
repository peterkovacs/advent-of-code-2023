// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

extension ParsableCommand {
  var stdin: AnyIterator<String> {
    .init { readLine(strippingNewline: true) }
  }

  var grid: Grid<Character> {
    let input = Array(stdin)
    return Grid(input.joined(), size: .init(x: input[0].count, y: input.count))
  }

  func infiniteGrid(_ default: @escaping (Coord) -> Character) -> InfiniteGrid<Character> {
    let input = Array(stdin)
    return InfiniteGrid(
      input.joined(),
      size: .init(x: input[0].count, y: input.count),
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
