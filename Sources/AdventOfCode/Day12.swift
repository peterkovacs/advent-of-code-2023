import Algorithms
import ArgumentParser
import Foundation
import Parsing

struct Day12: ParsableCommand { 
  enum State: String, CaseIterable {
    case unknown = "?"
    case spring  = "."
    case damaged = "#"
  }

  struct Puzzle {
    var layout: [State]
    var counts: [Int]

    struct Key: Hashable {
      let layout: ArraySlice<State>.Index
      let counts: ArraySlice<Int>.Index
    }

    static let parser: some Parsing.Parser<Substring.UTF8View, Self> = Parse {
      Puzzle(layout: $0, counts: $1)
    } with: {
      Many { State.parser() }
      Whitespace()
      Many { Int.parser() } separator: { ",".utf8 } terminator: { End() }
    }
  }

  func run() throws {
    let puzzle = try input.map(Puzzle.parser.parse)
    do {
      let part1 = puzzle.reduce(0) { partialResult, i in
        var cache: [Puzzle.Key: Int?] = [:]
        let total = (i.layout[...].place(widths: i.counts[...], cache: &cache) ?? 0)
        return partialResult + total
      }

      print("Part 1", part1)
    }

    do {
      let result = puzzle.enumerated().map { p in
        var cache: [Puzzle.Key: Int?] = [:]
        let unfolded = Puzzle(
          layout: Array(chain(p.element.layout, [.unknown]).cycled(times: 5).dropLast()),
          counts: Array(p.element.counts.cycled(times: 5))
        )
        return (unfolded.layout[...].place(widths: unfolded.counts[...], cache: &cache) ?? 0)
      }
      
      print("Part 2", result.reduce(0, +))
    }
  }
}

extension ArraySlice where Element == Day12.State {
  func place(widths: ArraySlice<Int>, cache: inout [Day12.Puzzle.Key: Int?]) -> Int? {
    let key = Day12.Puzzle.Key(layout: self.startIndex, counts: widths.startIndex)
    if let cached = cache[key] {
      return cached
    }

    guard let width = widths.first else {
      // if there are no items less to place then this placement is only valid if there are no # remaining
      let result = self.allSatisfy { $0 != .damaged } ? 1 : nil
      cache[key] = result
      return result
    }

    // the last possible place to put this span ends on the first damaged spring
    let range = startIndex...(firstIndex(of: .damaged) ?? endIndex)
    var start = startIndex
    var count = nil as Int?

    while range.contains(start), let (placement, rest) = self[start...].place(width: width) {
      precondition(range.contains(placement))
      precondition(rest == endIndex || placement + width + 1 == rest)

      // we could place widths[0] at `placement`. The rest of the widths will be place after `rest`
      if let total = self[rest...].place(widths: widths.dropFirst(), cache: &cache) {
        // we could place the rest of the widths in `rest...` so increment the total and
        // try again at the next position
        count = (count ?? 0) + total
        start = placement + 1
      } else if self[placement] == .damaged {
        // We have to place the width starting here, but couldn't place the rest, don't bother placing more.
        break
      } else {
        precondition(self[placement] == .unknown)
        // we could NOT place the rest of the widths in `rest...`, meaning there were more broken springs than numbers.
        // try again by consuming the next broken spring into this width
        start = Swift.max(
          start + 1,
          self[placement...].firstIndex(of: .damaged).map { $0 - width + 1 } ?? endIndex
        )
      }
    }

    cache[key] = count

    return count
  }


  func place(width: Int) -> (first: Index, next: Index)? {
    guard count >= width else { return nil }

    let canPlace = prefix(width).allSatisfy { $0 == .damaged || $0 == .unknown } && dropFirst(width).isNotContinued
    if canPlace {
      return (startIndex, dropFirst(width + 1).startIndex)
    } else if first == .damaged {
      return nil
    } else {
      return dropFirst().place(width: width)
    }
  }

  var isNotContinued: Bool {
    guard let first = first else { return true }
    return first == .spring || first == .unknown
  }
}
