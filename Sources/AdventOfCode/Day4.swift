
import ArgumentParser
import Parsing

struct Day4: ParsableCommand {
  enum Parsers {
    static var parser: some Parser<Substring, (Int, Set<Int>, Set<Int>)> {
      Parse {
        "Card"
        Whitespace()
        Int.parser()
        ":"

        Whitespace()

        Parse {
          Set($0)
        } with: {
          Many {
            Int.parser()
          } separator: {
            Whitespace()
          } terminator: {
            Whitespace()
            "|"
            Whitespace()
          }
        }

        Parse {
          Set($0)
        } with: {
          Many {
            Int.parser()
          } separator: {
            Whitespace()
          } terminator: {
            End()
          }
        }
      }
    }
  }
  mutating func run() throws {
    let input = try self.input.map(Parsers.parser.parse)

    let part1 = input.map { _, winning, own in
      let count = winning.intersection(own).count
      if count > 0 {
        return 1 << (count - 1)
      } else {
        return 0
      }
    }.reduce(0, +)

    print("Part 1:", part1)

    let part2 = input.indexed().reduce(into: [:] as [Int: Int]) { partialResult, card in
      partialResult[card.index, default: 0] += 1
      let multiplier = partialResult[card.index, default: 1]
      let count = card.element.1.intersection(card.element.2).count
      if count > 0 {
        for index in ((card.index + 1)..<(card.index + count + 1)).clamped(to: input.indices) {
          partialResult[index, default: 0] += multiplier
        }
      }
    }.values.reduce(0, +)

    print("Part 2:", part2)
  }
}

