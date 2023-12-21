
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
    let elementGrid = grid.map {
      switch $0 {
      case ".", "S": return Element.empty
      case "#": return .rock
      default: fatalError()
      }
    }

    let part1 = gardens(
      grid: elementGrid,
      start: start,
      steps: steps
    )
    print("Part 1", part1)

    print(grid.description.dropLast())
    print(grid.description.dropLast())
    print(grid)

    let above = elementGrid.indices.filter { elementGrid[$0] == .empty }.map { $0 + Coord(x: 0, y: -grid.size.y) }.map { count(grid: elementGrid, start: start, end: $0) }
    let below = elementGrid.indices.filter { elementGrid[$0] == .empty }.map { $0 + Coord(x: 0, y: grid.size.y) }.map { count(grid: elementGrid, start: start, end: $0) }

    print(above)
    print(below)

//    print(above.reversed().elementsEqual(below))

    let part2 = infiniteGardens(
      grid: elementGrid,
      start: start,
      steps: steps
    )
    print("Part 2", part2)
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

fileprivate func count(grid: Grid<Day21.Element>, start: Coord, end: Coord) -> Int {
  var q = Set<Coord>()
  var dist = [Coord: Int]()
  var heap = Heap<Visit>([.init(position: start, cost: 0)])

  dist[start] = 0

  while let p = heap.popMin() {
    q.insert(p.position)

    // Already found a faster path to this position
    guard dist[p.position] == p.cost else { continue }
    guard p.position != end else {
      print("From \(start) to \(end): \(p.cost)")
      return p.cost
    }

    for neighbor in p.position.adjacent where grid[neighbor % grid.size] == .empty && !q.contains(neighbor) {
      let alt = p.cost + 1
      if alt < dist[neighbor, default: Int.max] {
        heap.insert(.init(position: neighbor, cost: alt))
        dist[neighbor] = alt
      }
    }
  }

  fatalError()
}

fileprivate func infiniteGardens(grid: Grid<Day21.Element>, start: Coord, steps: Int) -> Int {
  var q = Set<Coord>()
  var dist = [Coord: Int]()
  var heap = Heap<Visit>([.init(position: start, cost: 0)])

  dist[start] = 0

  while let p = heap.popMin() {
    q.insert(p.position)

    // Already found a faster path to this position
    guard dist[p.position] == p.cost else { continue }
    guard p.cost < steps else { continue }

    for neighbor in p.position.adjacent where grid[neighbor % grid.size] == .empty && !q.contains(neighbor) {
      let alt = p.cost + 1
      if alt < dist[neighbor, default: Int.max] {
        heap.insert(.init(position: neighbor, cost: alt))
        dist[neighbor] = alt
      }
    }
  }

  let reachableInOdd = Set(dist.filter { $0.value % 2 == (steps % 2) }.keys.map { $0 % grid.size })
  let empty = Set(grid.indices.filter { grid[$0] == .empty })
  print("unreachable:")
  print(empty.subtracting(reachableInOdd))

  // print(dist.filter { $0.value % 2 == (steps % 2) }.keys.grouped { $0 % grid.size }.mapValues(\.count).sorted(by: { $0.key < $1.key }))

  return dist.values.filter { $0 % 2 == (steps % 2) }.count
}
