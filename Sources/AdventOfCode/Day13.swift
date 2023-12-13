
import ArgumentParser
import Parsing
import Utility
import Foundation

struct Day13: ParsableCommand {
  enum Parser {
    static let grid = Many(into: (.zero, [])) { (partialResult: inout (Coord, [Substring.UTF8View]), i: Substring.UTF8View) in
      partialResult.0.x = i.count
      partialResult.0.y += 1
      partialResult.1.append(i)
    } element: {
      Prefix<Substring.UTF8View> { $0 == 46 || $0 == 35 }
    } separator: {
      Whitespace(1, .vertical)
      Peek { Not { Whitespace(1, .vertical) } }
    }.map {
      Grid($0.1.joined(), size: $0.0)
    }

    static let parser: some Parsing.Parser<Substring.UTF8View, [Grid<Substring.UTF8View.Element>]> = Many {
      grid
    } separator: {
      Whitespace(2, .vertical)
    } terminator: {
      End()
    }
  }

  func run() throws {
    let grids: [Grid<Substring.UTF8View.Element>] = try Parser.parser.parse(stdin)

    let part1 = grids.reduce(0) { $0 + $1.mirror(allowed: 0) }
    print("Part 1", part1)

    let part2 = grids.reduce(0) { $0 + $1.mirror(allowed: 1) }
    print("Part 2", part2)

  }
}

struct RowMirrorIterator: Sequence, IteratorProtocol {
  let size: Coord
  var top, bottom: Coord

  public mutating func next() -> (Coord, Coord)? {
    if top.x >= size.x {
      top = .init(x: 0, y: top.y - 1)
      bottom = .init(x: 0, y: bottom.y + 1)
    }

    if top.y < 0 || bottom.y >= size.y { return nil }
    defer {
      top = top.right
      bottom = bottom.right
    }

    return (top, bottom)
  }
}
struct ColMirrorIterator: Sequence, IteratorProtocol {
  let size: Coord
  var left, right: Coord

  public mutating func next() -> (Coord, Coord)? {
    if left.y >= size.y {
      left = .init(x: left.x - 1, y: 0)
      right = .init(x: right.x + 1, y: 0)
    }

    if left.x < 0 || right.x >= size.x { return nil }
    defer {
      left = left.down
      right = right.down
    }

    return (left, right)
  }
}

private extension Grid where Element == Substring.UTF8View.Element {
  func mirror(allowed: Int) -> Int {
    for col in 1..<(size.x) {
      let match = ColMirrorIterator(size: size, left: .init(x: col - 1, y: 0), right: .init(x: col, y: 0))
        .lazy
        .filter { self[$0.0] != self[$0.1] }
        .prefix(allowed + 1)
        .count

      if match == allowed { return col }
    }

    for row in 1..<(size.y) {
      let match = RowMirrorIterator(size: size, top: .init(x: 0, y: row - 1), bottom: .init(x: 0, y: row))
        .lazy
        .filter { self[$0.0] != self[$0.1] }
        .prefix(allowed + 1)
        .count

      if match == allowed { return row * 100 }
    }

    fatalError()
  }

}
