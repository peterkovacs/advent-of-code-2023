
import ArgumentParser
import Utility

struct Day13: ParsableCommand {
  func run() throws {
    let grids = stdin.split(separator: #/\n\n/#).map {
      let lines = $0.split(separator: "\n")
      return Grid.init(lines.joined(), size: .init(x: lines[0].count, y: lines.count))
    }

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

private extension Grid where Element == Character {
  func mirror(allowed: Int) -> Int {
    for col in 1..<(size.x) {
      let match = ColMirrorIterator(size: size, left: .init(x: col - 1, y: 0), right: .init(x: col, y: 0))
        .lazy.filter { self[$0.0] != self[$0.1] }.count

      if match == allowed { return col }
    }

    for row in 1..<(size.y) {
      let match = RowMirrorIterator(size: size, top: .init(x: 0, y: row - 1), bottom: .init(x: 0, y: row))
        .lazy.filter { self[$0.0] != self[$0.1] }.count

      if match == allowed { return row * 100 }
    }

    fatalError()
  }

}
