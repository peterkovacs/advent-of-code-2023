
import ArgumentParser
import Parsing
import Utility
import CasePaths
import Collections

struct Day22: ParsableCommand {
  enum Parser {
    static let coord: some Parsing.Parser<Substring, Coord3> = Parse(Coord3.init(x:y:z:)) {
      Int.parser()
      ","
      Int.parser()
      ","
      Int.parser()
    }

    static let brick: some Parsing.Parser<Substring, (Coord3, Coord3)> = Parse {
      coord
      "~"
      coord
    }
  }

  @CasePathable
  enum Element {
    case empty
    case brick(Int, Int)
  }

  func run() throws {
    let bricks = try input.map(Parser.brick.parse).sorted { $0.0.min(z: $0.1) < $1.0.min(z: $1.1) }
    var grid = InfiniteGrid(repeating: Element.empty, size: .zero)
    var supporting: [Int: Set<Int>] = [:]
    var supportedBy: [Int: Set<Int>] = [:]

    for (offset, (a, b)) in bricks.enumerated() {
      let (axis, length) = a.axis(to: b)

      let height = (0..<length).map {
        grid[(a + .init(keyPath: axis, value: $0)).project(.xy)]
      }.compactMap {
        $0[case: \.brick]?.1
      }.max() ?? 0

      for i in 0..<length {
        let pos = (a + .init(keyPath: axis, value: i)).project(.xy)

        switch grid[pos] {
        case .empty:
          grid[pos] = .brick(offset, height + 1)
        case .brick(offset, let height):
          grid[pos] = .brick(offset, height + 1)
        case .brick(let c, height):
          supporting[c, default: .init()].insert(offset)
          supportedBy[offset, default: .init()].insert(c)
          grid[pos] = .brick(offset, height + 1)
        case let .brick(_, h) where h < height:
          grid[pos] = .brick(offset, height + 1)
        case let .brick(_, h) where h >= height:
          fatalError()
        default:
          fatalError()
        }

      }
    }

    let part1 = (0..<bricks.count).filter { i in
      let supporting = supporting[i, default: .init()]
      return supporting.isEmpty || supporting.allSatisfy { supportedBy[$0, default: .init()].count > 1 }
    }.count

    print("Part 1", part1)

    let part2 = (0..<bricks.count)
      .lazy
      .map { brick in
        var falling: Set<Int> = [ brick ]
        var queue: Deque = .init(supporting[brick, default: .init()])

        while let brick = queue.popFirst() {
          if supportedBy[brick, default: .init()].isSubset(of: falling) {
            falling.insert(brick)
            queue.append(contentsOf: supporting[brick, default: .init()])
          }
        }

        return falling.count
      }
      .reduce(0) { $0 + $1 - 1 }

    print("Part 2", part2)
  }
}

fileprivate extension Coord3 {
  init(keyPath: WritableKeyPath<Self, Int>, value: Int) {
    self.init(x: 0, y: 0, z: 0)
    self[keyPath: keyPath] = value
  }

  func max(z rhs: Self) -> Int {
    Swift.max(self.z, rhs.z)
  }

  func min(z rhs: Self) -> Int {
    Swift.min(self.z, rhs.z)
  }



  func axis(to rhs: Self) -> (axis: WritableKeyPath<Coord3, Int>, length: Int) {
    if self.x != rhs.x {
      return (\.x, abs(rhs.x - self.x) + 1)
    } else if self.y != rhs.y {
      return (\.y, abs(rhs.y - self.y) + 1)
    } else if self.z != rhs.z {
      return (\.z, abs(rhs.z - self.z) + 1)
    } else {
      return (\.x, 1)
    }
  }
}
