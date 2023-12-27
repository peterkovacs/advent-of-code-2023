
import ArgumentParser
import Collections
import Utility
import Algorithms

struct Day21: ParsableCommand { 
  enum Element {
    case empty, rock
  }

  @Argument var steps: Int = 64
  func run() {
    let grid = self.grid
    let start = grid.indices.first { grid[$0] == "S" }!
    var elementGrid = grid.map {
      switch $0 {
      case ".", "S": return Element.empty
      case "#": return .rock
      default: fatalError()
      }
    }

    // set any inaccessible positions to be .rock
    let inaccessible = elementGrid.indices.filter {
      elementGrid[$0] == .empty && elementGrid.neighbors(adjacent: $0).allSatisfy({ elementGrid[$0] == .rock })
    }

    inaccessible.forEach { elementGrid[$0] = .rock }

    let part1 = gardens(
      grid: elementGrid,
      start: start,
      steps: steps
    )
    print("Part 1", part1.even)

    let grids: Int = steps / elementGrid.size.x
    let remainder: Int = steps % elementGrid.size.x

    // how many squares can we reach with an even/odd number of steps
    let reachable = gardens(
      grid: elementGrid,
      start: start,
      steps: remainder + grid.size.x
    )

    let top = gardens(
      grid: elementGrid,
      start: .init(x: start.x, y: 0),
      steps: grid.size.x - 1
    )

    let bottom = gardens(
      grid: elementGrid,
      start: .init(x: start.x, y: elementGrid.size.y - 1),
      steps: grid.size.x - 1
    )

    let left = gardens(
      grid: elementGrid,
      start: .init(x: 0, y: start.y),
      steps: grid.size.x - 1
    )

    let right = gardens(
      grid: elementGrid,
      start: .init(x: elementGrid.size.x - 1, y: start.y),
      steps: grid.size.x - 1
    )

    let bottomLeft = [remainder - 1, remainder + grid.size.x - 1].map { i in
      gardens(
        grid: elementGrid,
        start: .init(x: 0, y: elementGrid.size.y - 1),
        steps: i
      )
    }

    let bottomRight = [remainder - 1, remainder - 1 + grid.size.x].map { i in
      gardens(
        grid: elementGrid,
        start: .init(x: elementGrid.size.x - 1, y: elementGrid.size.y - 1),
        steps: i
      )
    }

    let topLeft = [remainder - 1, remainder - 1 + grid.size.x].map { i in
      gardens(
        grid: elementGrid,
        start: .init(x: 0, y: 0),
        steps: i
      )
    }

    let topRight = [remainder - 1, remainder - 1 + grid.size.x].map { i in
      gardens(
        grid: elementGrid,
        start: .init(x: elementGrid.size.x - 1, y: 0),
        steps: i
      )
    }

    var part2 = 0
    for (parity, i) in zip([\(even:Int,odd:Int).odd, \.even].cycled(), 0..<grids) {
      part2 += max(1, i * 4) * reachable[keyPath: parity]
    }

    // I'm really not sure why these axes are \.even and not \.odd, which is what I would expect.
    part2 += bottom.even + top.even + left.even + right.even
    part2 += bottomLeft[1].odd * (grids - 1) + bottomRight[1].odd * (grids - 1) + topLeft[1].odd * (grids - 1) + topRight[1].odd * (grids - 1)
    part2 += bottomLeft[0].even * grids + bottomRight[0].even * grids + topLeft[0].even * grids + topRight[0].even * grids
    print("Part 2", part2)

  }
}

fileprivate struct Visit: Comparable {
  let position: Coord
  let steps: Int
  let distance: Int

  static func <(lhs: Self, rhs: Self) -> Bool {
    (lhs.steps + lhs.distance) < (rhs.steps + rhs.distance)
  }
}

fileprivate func gardens(grid: Grid<Day21.Element>, start: Coord, steps: Int) -> (even: Int, odd: Int) {
  var q = Set(grid.indices.filter { grid[$0] == .empty })
  var dist = [Coord: Int]()
  var heap = Heap<Visit>([.init(position: start, steps: 0, distance: 0)])

  dist[start] = 0

  while let p = heap.popMin() {
    q.remove(p.position)

    // Already found a faster path to this position
    guard dist[p.position] == p.steps else { continue }
    guard p.steps < steps else { continue }

    for neighbor in grid.neighbors(adjacent: p.position) where q.contains(neighbor) {
      let alt = p.steps + 1
      if alt < dist[neighbor, default: Int.max] {
        heap.insert(.init(position: neighbor, steps: alt, distance: 0))
        dist[neighbor] = alt
      }
    }
  }

  let total = dist.values.count
  let even = dist.values.lazy.filter { $0 % 2 == 0 }.count
  let odd = total - even

  return (even, odd)
}
