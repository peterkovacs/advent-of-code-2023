
import Algorithms
import ArgumentParser
import Parsing
import Utility
import Foundation

struct Day18: ParsableCommand { 
  enum Parser {
    static let instruction = Parse {
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

  func run() throws {
    let instructions = try input.map(Parser.instruction.parse)
    let coordinates = instructions.reductions(Coord.zero) {
      $0 + ($1.0 * $1.1)
    }

    assert(coordinates[0] == coordinates.last)
    let offset = Coord(
      x: coordinates.map(\.x).min()!,
      y: coordinates.map(\.y).min()!
    ) + .left.up
    let translation = CGAffineTransform.identity
      .translatedBy(
        x: -CGFloat(offset.x),
        y: -CGFloat(offset.y)
      )

    let size = Coord(
      x: coordinates.map(\.x).max()!,
      y: coordinates.map(\.y).max()!
    ).applying(translation) + (.down.right * 2)

    var output = Grid(repeating: "." as Character, size: size)
    var windings = Grid(repeating: 0, size: size)
    var cursor = Coord.zero.applying(translation)

    for instruction in instructions {
      switch instruction.0 {
      case .up:
        (0..<instruction.1).forEach {
          output[cursor + (instruction.0 * $0)] = "#"
        }
        (0..<instruction.1).forEach {
          windings[cursor + (instruction.0 * $0)] = 1
        }
      case .down:
        (0..<instruction.1).forEach {
          output[cursor + (instruction.0 * $0)] = "#"
        }
        (1...instruction.1).forEach {
          windings[cursor + (instruction.0 * $0)] = -1
        }
      case .left, .right:
        (0..<instruction.1).forEach {
          output[cursor + (instruction.0 * $0)] = "#"
        }

      default: break
      }

      cursor = cursor + instruction.0 * instruction.1
    }

    var inside = 0
    for point in windings.indices {
      var p = point
      var wn = 0
      while windings.isValid(p) {
        wn += windings[p]
        p = p.right
      }

      if wn != 0 {
        output[point] = "#"
        inside += 1
      }
    }

    print("Part 1", output.filter { $0 == "#" }.count)
    // print("Part 1", inside)
//
//    let min = coordinates.min(by: <)!.applying(translation)
//    let max = coordinates.max(by: <)!.applying(translation)
//
//    print(min, max, offset, offset.applying(translation.inverted()))
//
//    print(instructions.map(\.1).reduce(0, +))
//
//    let area = zip(
//      zip(
//        coordinates,
//        coordinates.dropFirst()
//      )
//      .lazy
//      .map { (a,b) -> Int in
//        (a.x * b.y)
//      },
//
//      zip(
//        coordinates.dropFirst(),
//        coordinates
//      )
//      .lazy
//      .map { (a,b) -> Int in
//        (a.x * b.y)
//      }
//    )
//      .reduce(0) { $0 + ($1.0 - $1.1) }
//
//    print("Part 1", area)
  }
}

