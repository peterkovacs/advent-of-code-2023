
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

    part2 += bottom.odd + top.odd + left.odd + right.odd
    part2 += bottomLeft[1].odd * (grids - 1) + bottomRight[1].odd * (grids - 1) + topLeft[1].odd * (grids - 1) + topRight[1].odd * (grids - 1)
    part2 += bottomLeft[0].even * grids + bottomRight[0].even * grids + topLeft[0].even * grids + topRight[0].even * grids
    print("Part 2", part2)

  }
}

fileprivate extension Coord {
  var parity: WritableKeyPath<(even: Int, odd: Int), Int> {
    (x + y) % 2 == 0 ? \.even : \.odd
  }
}

fileprivate extension KeyPath where Root == (even: Int, odd: Int), Value == Int {
  var next: WritableKeyPath<Root, Value> {
    switch self {
    case \.even: return \(even: Int, odd: Int).odd
    case \.odd: return \(even: Int, odd: Int).even
    default: fatalError()
    }
  }
}

fileprivate func gardens(grid: Grid<Day21.Element>, start: Coord, steps: Int) -> (even: Int, odd: Int) {
  var visited: Set<Coord> = [ start ]
  var queue: Deque = [ (start, start.parity, steps) ]
  var result =  (even: 0, odd: 0)

  while let (pos, parity, steps) = queue.popFirst() {
    result[keyPath: parity] += 1
    guard steps > 0 else { continue }
    for neighbor in grid.neighbors(adjacent: pos) where grid[neighbor] == .empty && visited.insert(neighbor).inserted {
      queue.append((neighbor, parity.next, steps - 1))
    }
  }

  return result
}
