
import Algorithms
import ArgumentParser
import Parsing
import Utility
import Foundation

struct Day18: ParsableCommand { 
  typealias Instruction = (direction: Coord, length: Int, color: (Int, Coord))
  enum Parser {
    static let instruction: some Parsing.Parser<Substring, Instruction> = Parse {
      (direction: $0.0, length: $0.1, color: $0.2)
    } with: {
      OneOf {
        "U".map { Coord.up }
        "R".map { .right }
        "L".map { .left }
        "D".map { .down}
      }

      Whitespace()
      Int.parser()
      Whitespace()

      Parse {
        "(#"
        Parse {
          Prefix<Substring>(5)
        }
        .compactMap {
          Int($0, radix: 16)
        }

        // 0 means R, 1 means D, 2 means L, and 3 means U.
        OneOf {
          "0".map { Coord.right }
          "1".map { .down }
          "2".map { .left }
          "3".map { .up }
        }
         ")"
      }
    }
  }

  struct Part1: Sequence, IteratorProtocol {
    var cursor = Coord.zero
    var instructions: [Instruction]
    var index: [Instruction].Index

    init(
      cursor: Coord = Coord.zero,
      instructions: [Instruction]
    ) {
      self.cursor = cursor
      self.instructions = instructions
      self.index = instructions.startIndex
    }

    mutating func next() -> Coord? {
      if index == instructions.endIndex { return nil }

      defer {
        let prev = instructions[
          (index - 1 + instructions.count) % instructions.count
        ].direction

        let curr = instructions[index]

        let next = instructions[
          (index + 1) % instructions.count
        ].direction

        if prev == next {
          cursor = cursor + (curr.direction * curr.length)
        } else if prev.clockwise == curr.direction,
                  curr.direction.clockwise == next {
          cursor = cursor + (curr.direction * (curr.length + 1))
        } else if prev.counterClockwise == curr.direction,
                  curr.direction.counterClockwise == next {
          cursor = cursor + (curr.direction * (curr.length - 1))
        } else {
          fatalError()
        }

        index += 1
      }

      return cursor
    }
  }

  struct Part2: Sequence, IteratorProtocol {
    var cursor = Coord.zero
    var instructions: [Instruction]
    var index: [Instruction].Index

    init(
      cursor: Coord = Coord.zero,
      instructions: [Instruction]
    ) {
      self.cursor = cursor
      self.instructions = instructions
      self.index = instructions.startIndex
    }

    mutating func next() -> Coord? {
      if index == instructions.endIndex { return nil }

      defer {
        let prev = instructions[
          (index - 1 + instructions.count) % instructions.count
        ].color.1

        let curr = instructions[index]

        let next = instructions[
          (index + 1) % instructions.count
        ].color.1

        if prev == next {
          cursor = cursor + (curr.color.1 * curr.color.0)
        } else if prev.clockwise == curr.color.1,
                  curr.color.1.clockwise == next {
          cursor = cursor + (curr.color.1 * (curr.color.0 + 1))
        } else if prev.counterClockwise == curr.color.1,
                  curr.color.1.counterClockwise == next {
          cursor = cursor + (curr.color.1 * (curr.color.0 - 1))
        } else {
          fatalError()
        }

        index += 1
      }

      return cursor
    }
  }

  func area(of coordinates: [Coord]) -> Int {
    zip(
      zip(
        coordinates,
        chain( coordinates.dropFirst(), coordinates.prefix(1) )
      )
      .lazy
      .map { (a: Coord, b: Coord) -> Int in
        (a.x - b.x)
      },

      zip(
        chain( coordinates.dropFirst(), coordinates.prefix(1) ),
        coordinates
      )
      .lazy
      .map { (a: Coord, b: Coord) -> Int in
        (a.y + b.y)
      }
    )
    .reduce(0) { $0 + ($1.0 * $1.1) } / 2
  }

  func run() throws {
    let instructions = try input.map(Parser.instruction.parse)

    let part1 = area(of: Array(Part1(instructions: instructions)))
    print("Part 1", part1)

    let part2 = area(of: Array(Part2(instructions: instructions)))
    print("Part 2", part2)
  }
}

