import Algorithms
import ArgumentParser
import Collections
import Utility

struct Day16: ParsableCommand { 
  enum Element {
    case empty
    case mirrorL
    case mirrorR
    case splitX
    case splitY
  }

  struct Vector: Hashable {
    var p: Coord
    var v: Coord

    mutating func apply(_ element: Element) -> Self? {
      switch element {
      case .mirrorL:
        switch v { // \
        case .right: v = .down
        case .down:  v = .right
        case .up:    v = .left
        case .left:  v = .up
        default: fatalError()
        }
        p = p + v
      case .mirrorR:
        switch v { // /
        case .right: v = .up
        case .down:  v = .left
        case .up:    v = .right
        case .left:  v = .down
        default: fatalError()
        }
        p = p + v

      case .splitX where v.y != 0:
        defer {
          v = .right
          p = p + v
        }

        return .init(p: p + .left, v: .left)
      case .splitY where v.x != 0:
        defer {
          v = .up
          p = p + v
        }

        return .init(p: p + .down, v: .down)

      default: p = p + v
      }

      return nil
    }
  }

  mutating func run() {
    let grid = self.grid.map {
      switch $0 {
      case "/":  return Element.mirrorR
      case "\\": return Element.mirrorL
      case "-":  return Element.splitX
      case "|":  return Element.splitY
      default:   return Element.empty
      }
    }

    func solve(grid: Grid<Element>, start: Vector) -> Int {
      var positions: Set<Coord> = [start.p]
      var vectors: Set<Vector> = [start]
      var queue: Deque<Vector> = .init(vectors)

      while !queue.isEmpty {
        var v = queue.removeFirst()
        positions.insert(v.p)

        if let new = v.apply(grid[v.p]), grid.isValid(new.p) {
          if vectors.insert(new).inserted {
            queue.append(new)
          }
        }

        if grid.isValid(v.p), vectors.insert(v).inserted {
          queue.append(v)
        }
      }

      return positions.count
    }

    print("Part 1", solve(grid: grid, start: .init(p: .zero, v: .right)))

    let part2 = chain(
      chain(
        (0..<grid.size.x).map { Vector(p: .init(x: $0, y: 0), v: .down) },
        (0..<grid.size.x).map { Vector(p: .init(x: $0, y: grid.size.y - 1), v: .up) }
      ),
      chain( 
        (0..<grid.size.y).map { Vector(p: .init(x: 0, y: $0), v: .right) },
        (0..<grid.size.y).map { Vector(p: .init(x: grid.size.x - 1, y: $0), v: .left) }
      )
    ).map {
      solve(grid: grid, start: $0)
    }.max()!

    print("Part 2", part2)
  }
}

