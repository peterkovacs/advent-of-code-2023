import ArgumentParser
import Collections
import Utility
import Algorithms

struct Day17: ParsableCommand {

  func run() throws {
    // let grid = Grid(try String(contentsOfFile: "/Users/peter/Developer/Personal/AdventOfCode2023/example17.1.txt").split(separator: "\n").joined(), size: .init(x: 12, y: 5))
    let grid = self.grid
      .map { Int(String($0))! }

    if let part1 = dijkstra(grid: grid, start: .zero, end: grid.size - .init(x: 1, y: 1), straight: 0..<4, turn: 0..<Int.max, stop: 0..<4) {
      print("Part 1", part1)
    }

    if let part2 = dijkstra(grid: grid, start: .zero, end: grid.size - .init(x: 1, y: 1), straight: 0..<10, turn: 4..<Int.max, stop: 4..<10) {
      print("Part 2", part2)
    }
  }
}

fileprivate struct Visit: Hashable {
  let vector: Vector
  let count: Int

  func abs() -> Self {
    .init(vector: vector.abs(), count: count)
  }
}

fileprivate struct VisitCost: Comparable {
  let visit: Visit
  let cost: Int

  static func <(lhs: Self, rhs: Self) -> Bool {
    lhs.cost < rhs.cost
  }
}

fileprivate func dijkstra(grid: Grid<Int>, start: Coord, end: Coord, straight: Range<Int>, turn: Range<Int>, stop: Range<Int>) -> Int? {
  var q = Grid<(Int, Int, Int, Int)>(repeating: (0, 0, 0, 0), size: grid.size)
  var dist = Grid<([Int], [Int], [Int], [Int])>(
    repeating: (
      Array(repeating: Int.max, count: straight.count + 1),
      Array(repeating: Int.max, count: straight.count + 1),
      Array(repeating: Int.max, count: straight.count + 1),
      Array(repeating: Int.max, count: straight.count + 1)
    ),
    size: grid.size
  )
  var heap = Heap<VisitCost>()

  do {
    let startVisit = Visit(vector: .init(position: start, direction: .right), count: 0)
    heap.insert(.init(visit: startVisit, cost: 0))
    dist[startVisit] = 0
  }

  do {
    let startVisit = Visit(vector: .init(position: start, direction: .down), count: 0)
    heap.insert(.init(visit: startVisit, cost: 0))
    dist[startVisit] = 0
  }

  while let u = heap.popMin() {
    if u.visit.vector.position == end,
       stop.contains(u.visit.count)
    { return u.cost }

    q.remove(u.visit)
    guard dist[u.visit] == u.cost else { continue }

    var neighbors: [Visit] = []

    if straight.contains(u.visit.count) {
      let direction = u.visit.vector.direction
      let position  = u.visit.vector.position + direction
      if grid.isValid(position) {
        let visit = Visit(vector: .init(position: position, direction: direction), count: u.visit.count + 1)
        neighbors.append(visit)
      }
    }

    if turn.contains(u.visit.count) {
      do {
        let direction = u.visit.vector.direction.clockwise
        let position  = u.visit.vector.position + direction
        if grid.isValid(position) {
          let visit = Visit(vector: .init(position: position, direction: direction), count: 1)
          neighbors.append(visit)
        }
      }

      do {
        let direction = u.visit.vector.direction.counterClockwise
        let position  = u.visit.vector.position + direction
        if grid.isValid(position) {
          let visit = Visit(vector: .init(position: position, direction: direction), count: 1)
          neighbors.append(visit)
        }
      }
    }

    for v in neighbors where q.contains(v) {
      let alt = u.cost + grid[v.vector.position]
      if alt < dist[v] {
        heap.insert(.init(visit: v, cost: alt))
        dist[v] = alt
      }
    }
  }

  fatalError()
}

fileprivate extension Grid where Element == (Int, Int, Int, Int) {
  mutating func remove(_ visit: Visit) {
    switch visit.vector.direction {
    case .up:    self[visit.vector.position].0 |= (1 << visit.count)
    case .down:  self[visit.vector.position].1 |= (1 << visit.count)
    case .left:  self[visit.vector.position].2 |= (1 << visit.count)
    case .right: self[visit.vector.position].3 |= (1 << visit.count)
    default: fatalError()
    }
  }

  mutating func contains(_ visit: Visit) -> Bool {
    switch visit.vector.direction {
    case .up:    (self[visit.vector.position].0 & (1 << visit.count)) == 0
    case .down:  (self[visit.vector.position].1 & (1 << visit.count)) == 0
    case .left:  (self[visit.vector.position].2 & (1 << visit.count)) == 0
    case .right: (self[visit.vector.position].3 & (1 << visit.count)) == 0
    default: fatalError()
    }
  }
}

fileprivate extension Grid where Element == ([Int], [Int], [Int], [Int]) {
  subscript(_ visit: Visit) -> Int {
    _read {
      switch visit.vector.direction {
      case .up:    yield self[visit.vector.position].0[visit.count]
      case .down:  yield self[visit.vector.position].1[visit.count]
      case .left:  yield self[visit.vector.position].2[visit.count]
      case .right: yield self[visit.vector.position].3[visit.count]
      default: fatalError()
      }
    }

    _modify {
      switch visit.vector.direction {
      case .up:    yield &self[visit.vector.position].0[visit.count]
      case .down:  yield &self[visit.vector.position].1[visit.count]
      case .left:  yield &self[visit.vector.position].2[visit.count]
      case .right: yield &self[visit.vector.position].3[visit.count]
      default: fatalError()
      }
    }
  }
}
