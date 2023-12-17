import ArgumentParser
import Collections
import Utility
import Algorithms

struct Day17: ParsableCommand {

  func run() throws {
    let grid = self.grid.map { Int(String($0))! }

    if let (part1, path) = dijkstra(grid: grid, start: .zero, end: grid.size - .init(x: 1, y: 1), straight: 0..<3, turn: 0..<Int.max, stop: 0..<3) {
      print("Part 1", part1)
    }

    if let (part2, path) = dijkstra(grid: grid, start: .zero, end: grid.size - .init(x: 1, y: 1), straight: 0..<11, turn: 4..<Int.max, stop: 4..<11) {
      print("Part 2", part2)
    }
  }
}

fileprivate struct Visit: Hashable {
  let vector: Vector
  let count: Int
}

fileprivate struct VisitCost: Comparable {
  let visit: Visit
  let cost: Int

  static func <(lhs: Self, rhs: Self) -> Bool {
    lhs.cost < rhs.cost
  }
}

func dijkstra(grid: Grid<Int>, start: Coord, end: Coord, straight: Range<Int>, turn: Range<Int>, stop: Range<Int>) -> (Int, [Vector])? {
  var q = Set<Visit>(grid.indices.flatMap { coord in
    product(
      [Coord.up, Coord.down, Coord.left, Coord.right],
      straight
    ).map {
      Visit(vector: .init(position: coord, direction: $0.0), count: $0.1)
    }
  })

  var prev = [Visit: Visit]()
  var dist = [Visit: Int]()
  var heap = Heap<VisitCost>()

  func path(from end: Visit) -> [Vector] {
    var result = [Vector]()
    var u = end as Visit?
    while u != nil {
      result.append(u!.vector)
      u = prev[u!]
    }

    return result
  }

  let ends = product(
    [Coord.down, Coord.right],
    stop
  ).map {
    Visit(vector: .init(position: end, direction: $0.0), count: $0.1)
  }

  var endsRemaining = Set(ends)


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

  while true {
    guard let u = heap.popMin() else { break }
    guard dist[u.visit] == u.cost else { continue }
    if u.visit.vector.position == end,
      endsRemaining.remove(u.visit) != nil,
      endsRemaining.isEmpty
    { break }

    q.remove(u.visit)

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
      let direction = u.visit.vector.direction.clockwise
      let position  = u.visit.vector.position + direction
      if grid.isValid(position) {
        let visit = Visit(vector: .init(position: position, direction: direction), count: 1)
        neighbors.append(visit)
      }
    }

    if turn.contains(u.visit.count) {
      let direction = u.visit.vector.direction.counterClockwise
      let position  = u.visit.vector.position + direction
      if grid.isValid(position) {
        let visit = Visit(vector: .init(position: position, direction: direction), count: 1)
        neighbors.append(visit)
      }
    }

    for v in neighbors where q.contains(v) {
      let alt = dist[u.visit]! + grid[v.vector.position]
      if alt < dist[v, default: Int.max] {
        heap.insert(.init(visit: v, cost: alt))
        dist[v] = alt
        prev[v] = u.visit
      }
    }
  }

  let end = ends.min { a, b in
    dist[a, default: Int.max] < dist[b, default: Int.max]
  }!

  return (dist[end]!, Array(path(from: end).reversed().dropFirst()))
}
