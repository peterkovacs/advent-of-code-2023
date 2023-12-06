
import ArgumentParser
import Parsing
import Foundation

struct Day6: ParsableCommand {
  enum Parser {
    static let parser = Parse {
      Array(zip($0, $1))
    } with: {
      "Time:"
      Many {
        Whitespace()
        Int.parser()
      } terminator: {
        Whitespace(.vertical)
      }

      "Distance:"
      Many {
        Whitespace()
        Int.parser()
      } terminator: {
        Optionally { Whitespace(.vertical) }
        End()
      }
    }
  }

  mutating func run() throws {
    let races = try Parser.parser.parse(stdin)

    let part1 = races.map { race in
      let a = -1.0
      let b = Double(race.0)
      let c = Double(-race.1)

      let ap = (Double(-b) + sqrt(Double( (b*b) - 4 * a * c))) / (2 * a)
      let bp = (Double(-b) - sqrt(Double( (b*b) - 4 * a * c))) / (2 * a)

      let lower = Double(Int(ap)) == ap ? Int(ap) + 1 : Int(ap.rounded(.up))
      let upper = Double(Int(bp)) == bp ? Int(bp) - 1 : Int(bp.rounded(.down))

      // print("Solutions to \(race): \(ap), \(bp) \(lower...upper)")

      return (lower...upper).count
    }.reduce(1, *)

    print("Part 1", part1)
  }
}

