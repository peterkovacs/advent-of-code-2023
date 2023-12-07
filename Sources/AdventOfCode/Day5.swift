
import ArgumentParser
import Algorithms
import Collections
import Parsing
import Foundation

struct Day5: ParsableCommand {

  struct Map: Comparable {
    let source: Range<Int>
    let offset: Int

    static func <(l: Self, r: Self) -> Bool {
      l.source.lowerBound == r.source.lowerBound ? l.source.upperBound < r.source.upperBound : l.source.lowerBound < r.source.lowerBound
    }

    static let parser: some Parsing.Parser<Substring.UTF8View, Self> = Parse {
      Map(source: $1..<($1 + $2), offset: $0 - $1)
    } with: {
      Int.parser() // destination range start
      " ".utf8
      Int.parser() // source range start
      " ".utf8
      Int.parser() // range length
    }
  }

  enum Parser {
    static var rangeMap: some Parsing.Parser<Substring.UTF8View, [Map]> = Parse { (result: [Map]) in
      result.sorted()
    } with: {
      Many {
        Map.parser
      } separator: {
        Whitespace(1, .vertical)
      } terminator: {
        OneOf {
          Whitespace(2, .vertical)
          Skip {
            Optionally { Whitespace(1, .vertical) }
            End()
          }
        }
      }
    }

    static var parser: some Parsing.Parser<Substring.UTF8View, ([Int], [[Map]])> = Parse {
      Parse {
        "seeds: ".utf8
        Many {
          Int.parser()
        } separator: {
          Whitespace(.horizontal)
        } terminator: {
          Whitespace(.vertical)
        }
      }

      Many {
        OneOf {
          "seed-to-soil map:".utf8
          "soil-to-fertilizer map:".utf8
          "fertilizer-to-water map:".utf8
          "water-to-light map:".utf8
          "light-to-temperature map:".utf8
          "temperature-to-humidity map:".utf8
          "humidity-to-location map:".utf8
        }
        Whitespace()
        rangeMap
      }
    }
  }

  func run() throws {
    let (seeds, maps) = try Parser.parser.parse(stdin)

    func calculate(i: Int) -> Int {
      minimum(range: i..<(i+1), layers: maps[...])
    }

    let part1 = seeds.map(calculate(i:)).min()!

    print("Part 1", part1)

    let part2 = seeds.indices.striding(by: 2).map {
      minimum(range: seeds[$0] ..< (seeds[$0] + seeds[$0+1]), layers: maps[...])
    }.min()!

    print("Part 2", part2)
  }

  func minimum(range: Range<Int>, layers: ArraySlice<[Map]>) -> Int {
    guard !layers.isEmpty else { return range.lowerBound }

    let destination = layers.first?.first { $0.source.overlaps(range) }
    guard let destination else { return minimum(range: range, layers: layers.dropFirst()) }

    if range.lowerBound < destination.source.lowerBound {
      return min(
        minimum(range: range.lowerBound..<destination.source.lowerBound, layers: layers.dropFirst()),
        minimum(range: destination.source.lowerBound..<range.upperBound, layers: layers)
      )
    } else if range.upperBound <= destination.source.upperBound {
      return minimum(
        range: range + destination.offset,
        layers: layers.dropFirst()
      )
    } else {
      return min(
        minimum(range: (range.lowerBound..<destination.source.upperBound) + destination.offset, layers: layers.dropFirst()),
        minimum(range: (destination.source.upperBound..<range.upperBound), layers: layers)
      )
    }
  }
}

private extension Range<Int> {
  static func +(l: Self, r: Int) -> Self {
    return (l.lowerBound + r) ..< (l.upperBound + r)
  }
}
