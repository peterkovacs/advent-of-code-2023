
import ArgumentParser
import Collections
import Utility

struct Day21: ParsableCommand { 
  enum Element {
    case empty, rock
  }

  @Argument var steps: Int = 64
  func run() {
    let grid = self.grid
    let start = grid.indices.first { grid[$0] == "S" }!

    let part1 = gardens(
      grid: grid.map {
        switch $0 {
        case ".", "S": return Element.empty
        case "#": return .rock
        default: fatalError()
        }
      }, 
      start: start,
      steps: steps
    )
    print("Part 1", part1)
  }
}

fileprivate struct Visit: Comparable {
  let position: Coord
  let cost: Int

  static func <(lhs: Self, rhs: Self) -> Bool {
    lhs.cost < rhs.cost
  }
}

fileprivate func gardens(grid: Grid<Day21.Element>, start: Coord, steps: Int) -> Int {
  var q = Set(grid.indices.filter { grid[$0] == .empty })
  var dist = [Coord: Int]()
  var heap = Heap<Visit>([.init(position: start, cost: 0)])

  dist[start] = 0

  while let p = heap.popMin() {
    q.remove(p.position)

    // Already found a faster path to this position
    guard dist[p.position] == p.cost else { continue }
    guard p.cost < steps else { continue }

    for neighbor in grid.neighbors(adjacent: p.position) where q.contains(neighbor) {
      let alt = p.cost + 1
      if alt < dist[neighbor, default: Int.max] {
        heap.insert(.init(position: neighbor, cost: alt))
        dist[neighbor] = alt
      }
    }
  }

  return dist.values.filter { $0 % 2 == 0 }.count
}
