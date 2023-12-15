
import Algorithms
import Collections
import ArgumentParser
import Foundation
import Utility

struct Day14: ParsableCommand {
  enum Element: Hashable {
    case empty
    case round
    case square
  }

  struct Cycle: Sequence, IteratorProtocol {
    let size: Coord
    var coords: [(Element, Coord)]

    init(grid: Grid<Element>) {
      self.size = grid.size
      self.coords = grid.indices
        .filter { grid[$0] != .empty }
        .sorted { $0.x == $1.x ? $0.y < $1.y : $0.x < $0.x  }
        .map { (grid[$0], $0) }
    }

    mutating func next() -> (hash: Int, load: Int)? {
      let (coords, load) = coords.cycle(size: size)
      return (coords, load)
    }
  }

  func run() throws {
    let grid = self.grid.map {
      switch $0 {
      case "O": return Element.round
      case "#": return Element.square
      default:  return Element.empty
      }
    }

    let part1 = grid.tilted.load
    print("Part 1", part1)

    var cache: [Int: (load: Int, offset: Int)] = [:]
    let part2 = zip(1..., Cycle(grid: grid))
      .first { (offset, element) in
        let (coords, load) = element
        if cache[coords] != nil {
          return true
        } else {
          cache[coords] = (load: load, offset: offset)
          return false
        }
      }!

    let start = cache[part2.1.0]!.offset
    let length = part2.0 - start
    let offset = (1000000000 - start) % length + start
    let load = cache.first { $0.value.offset == offset }!.value.load

    print("Part 2", load)
  }
}

private extension Array where Element == (Day14.Element, Coord) {

  // Returns the load assuming that the "east" side is facing north.
  mutating func tilt(size: Coord) -> Int {
    var result = 0
    let groups = self.grouped(by: \.1.x)
    self.removeAll(keepingCapacity: true)

    for col in 0..<size.x {
      if let group = groups[col] {
        var coord = Coord(x: col, y: 0)

        for (element, i) in group {
          if element == .round {
            self.append((.round, coord))
            result += (size.x - col)
            coord = coord.down
          } else if element == .square {
            self.append((.square, i))
            coord = i.down
          }
        }
      }
    }

    return result
  }

  mutating func cycle(size: Coord) -> (hash: Int, load: Int) {
    let transform: CGAffineTransform = .identity
      .translatedBy(x: CGFloat(size.x) / 2, y: CGFloat(size.y) / 2)
      .rotated(by: .pi / 2)
      .translatedBy(x: -CGFloat(size.y) / 2, y: -CGFloat(size.x) / 2 + 1),

    _ = tilt(size: size)
    self = self.map { ($0.0, $0.1.applying(transform)) }

    _ = tilt(size: size)
    self = self.map { ($0.0, $0.1.applying(transform)) }

    _ = tilt(size: size)
    self = self.map { ($0.0, $0.1.applying(transform)) }

    let result = tilt(size: size)
    self = self.map { ($0.0, $0.1.applying(transform)) }

    return (self.map(\.1).hashValue, result)
  }

}

private extension Grid where Element == Day14.Element {
  var load: Int {
    let grid = self.flipped
    return grid.indices.filter { grid[$0] == .round }.map { $0.y + 1 }.reduce(0, +)
  }

  // Returns the load assuming that the "east" side is facing north.
  mutating func tilt(coords hasher: inout Hasher?) -> Int {
    var result = 0
    for col in 0..<size.x {
      var coord = Coord(x: col, y: 0)
      for i in self.column(col) {
        if self[i] == .round {
          self[i] = .empty
          self[coord] = .round
          result += (size.x - col)
          hasher?.combine(coord)
          coord = coord.down
        } else if self[i] == .square {
          coord = i.down
        }
      }
    }
    return result
  }

  var tilted: Self {
    var result = self
    var coords = nil as Hasher?
    _ = result.tilt(coords: &coords)

    return result
  }
}
