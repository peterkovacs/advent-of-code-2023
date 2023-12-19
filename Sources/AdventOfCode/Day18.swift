
import Algorithms
import ArgumentParser
import Parsing
import Utility
import Foundation

struct Day18: ParsableCommand { 
  typealias Instruction = (direction: Coord, length: Int, color: String)
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
        Prefix(6)
        ")"
      }.map(.string)
    }
  }

  struct Instructions: Sequence, IteratorProtocol {
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

  func run() throws {
    let instructions = try input.map(Parser.instruction.parse)

    let coordinates = Array(Instructions(instructions: instructions))

//    let coordinates = instructions.reductions(Coord.zero) {
//      $0 + ($1.direction * $1.length)
//    }

    print(coordinates)
//    assert(coordinates[0] == coordinates.last)
//    let offset = Coord(
//      x: coordinates.map(\.x).min()!,
//      y: coordinates.map(\.y).min()!
//    )
//    let translation = CGAffineTransform.identity
//      .translatedBy(
//        x: -CGFloat(offset.x),
//        y: -CGFloat(offset.y)
//      )
//
//    let size = Coord(
//      x: coordinates.map(\.x).max()!,
//      y: coordinates.map(\.y).max()!
//    ).applying(translation) + .down.right
//
//    var output = Grid(repeating: "." as Character, size: size)
//    var windings = Grid(repeating: 0, size: size)
//    var cursor = Coord.zero.applying(translation)
//
//    for instruction in instructions {
//      switch instruction.0 {
//      case .up:
//        (0..<instruction.1).forEach {
//          output[cursor + (instruction.0 * $0)] = "I"
//        }
//        (0..<instruction.1).forEach {
//          windings[cursor + (instruction.0 * $0)] = 1
//        }
//      case .down:
//        (0..<instruction.1).forEach {
//          output[cursor + (instruction.0 * $0)] = "I"
//        }
//        (1...instruction.1).forEach {
//          windings[cursor + (instruction.0 * $0)] = -1
//        }
//      case .left, .right:
//        (0..<instruction.1).forEach {
//          output[cursor + (instruction.0 * $0)] = "I"
//        }
//
//      default: break
//      }
//
//      cursor = cursor + instruction.0 * instruction.1
//    }
//
//    var inside = 0
//    for point in windings.indices {
//      var p = point
//      var wn = 0
//      while windings.isValid(p) {
//        wn += windings[p]
//        p = p.right
//      }
//
//      if wn != 0 {
//        output[point] = "#"
//        inside += 1
//      }
//    }
//
//    print(output)
//
//    print("Part 1", output.filter { $0 == "#" }.count)
    // print("Part 1", inside)
//
//    let min = coordinates.min(by: <)!.applying(translation)
//    let max = coordinates.max(by: <)!.applying(translation)
//
//    print(min, max, offset, offset.applying(translation.inverted()))
//
//    print(instructions.map(\.1).reduce(0, +))
//
//    print(size, offset)

    let area = zip(
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

    // let boundary = instructions.map(\.length).reduce(0, +)

    print("Part 1", area)
  }
}

