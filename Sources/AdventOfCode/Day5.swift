
import ArgumentParser
import Algorithms
import Collections
import Parsing
import Foundation

struct Day5: ParsableCommand {

  struct Map {
    let source: Range<Int>
    let offset: Int
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
    static var rangeMap: AnyParser<Substring.UTF8View, [Map]> = Many {
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
    }.eraseToAnyParser()

    static var parser = Parse {
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

    let part1 = seeds.map {
      maps.reduce($0) { partialResult, i in
        i.find(input: partialResult)
      }
    }.min()!

    print("Part 1", part1)

    let seedRanges = seeds.indices.striding(by: 2).map {
      seeds[$0]..<(seeds[$0] + seeds[$0 + 1])
    }

    var result = [Int](repeating: 0, count: seedRanges.count)
    DispatchQueue.concurrentPerform(iterations: seedRanges.count) { i in
      result[i] = seedRanges[i].lazy.map {
        maps.reduce($0) { partialResult, i in
          i.find(input: partialResult)
        }
      }.min()!
    }

    print("Part 2", result, result.min()!)
  }
}

private extension Array where Element == Day5.Map {
  func find(input: Int) -> Int {
    input + (first { $0.source.contains(input) }?.offset ?? 0)
  }
}
