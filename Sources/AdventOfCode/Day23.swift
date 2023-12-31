
import ArgumentParser
import Utility
import Collections

struct Day23: ParsableCommand { 
  mutating func run() throws {
     var grid = grid

    let start = Coord(
      x: (0..<grid.size.x).first { grid[.init(x: $0, y: 0) ] == "." }!,
      y: 0
    )

    let goal = Coord(
      x: (0..<grid.size.x).first { grid[.init(x: $0, y: grid.size.y - 1) ] == "." }!,
      y: grid.size.y - 1
    )

    print(start, goal)

    var p1 = Set<Coord>()
    p1.reserveCapacity(grid.size.x * grid.size.y)

    let part1 = dfs(grid: grid, visited: &p1, position: start, goal: goal) {
      switch ($0, $1) {
      case (.up, "^"),    (.up, "."),
           (.down, "v"),  (.down, "."),
           (.left, "<"),  (.left, "."),
           (.right, ">"), (.right, "."):
        return true
      default: return false
      }
    }
    print("Part 1", part1 ?? 0)

    let junctions = find(junctions: grid).union([start, goal])
    let graph = find(edges: grid, junctions: junctions, start: start)

    let distances = Dictionary(
      graph.map { a, b, steps in
        (Edge(a: a, b: b), steps)
      }
    ) { $0 < $1 ? $1 : $0 }

    let edges = Dictionary(
      graph.flatMap { a, b, _ in
        [(a, Set([b])), (b, Set([a]))]
      }
    ) { $0.union($1) }


    var cache = [Key: Int?]()
    let part2 = dfs(graph: edges, distances: distances, visited: .init(), position: start, goal: goal, cache: &cache)!

    print("Part 2", part2)
  }

  struct Edge: Hashable {
    let a, b: Coord
    init(a: Coord, b: Coord) {
      self.a = a < b ? a : b
      self.b = a < b ? b : a
    }
  }

  func find(junctions grid: Grid<Character>) -> Set<Coord> {
    return Set(
      grid.indices.filter {
        grid[$0] != "#" && grid.neighbors(adjacent: $0).filter { grid[$0] != "#" }.count > 2
      }
    )
  }

  func find(edges grid: Grid<Character>, junctions: Set<Coord>, start: Coord) -> [(Coord, Coord, Int)] {
    var visited: Set<Coord> = []
    var queue: Deque = [ (start, start, 0) ]
    var result: [(Coord, Coord, Int)] = []

    func isNeighbor(_ coord: Coord, junction: Coord) -> Bool {
      guard grid[coord] != "#" else { return false }
      if junctions.contains(coord) && junction != coord { return true }
      return !visited.contains(coord)
    }

    while let (junction, p, steps) = queue.popFirst() {
      if junctions.contains(p) && p != junction {
        result.append((junction, p, steps))
      }

      visited.insert(p)

      let neighbors  = grid.neighbors(adjacent: p).filter {
        isNeighbor($0, junction: junction)
      }

      if junctions.contains(p) && p != junction {
        queue.append(
          contentsOf: neighbors.map {
            (p, $0, 1)
          }
        )
      } else {
        queue.prepend(
          contentsOf: neighbors.map {
            (junction, $0, steps + 1)
          }
        )
      }
    }

    return result
  }

  struct Key: Hashable {
    let visited: Set<Coord>
    let position: Coord
  }

  func dfs(graph: [Coord : Set<Coord>], distances: [Edge: Int], visited: Set<Coord>, position: Coord, goal: Coord, cache: inout [Key: Int?]) -> Int? {
    guard position != goal else { return 0 }

    let key = Key(visited: visited, position: position)

    if let cached = cache[key] { return cached }
    var result: Int? = nil

    for p in graph[position, default: .init()] where !visited.contains(p) {
      var visited = visited
      visited.insert(p)

      if let solution = dfs(graph: graph, distances: distances, visited: visited, position: p, goal: goal, cache: &cache) {
        result = max(result ?? 0, solution + distances[.init(a: position, b: p), default: 0])
      }
    }

    cache[.init(visited: visited, position: position)] = .some(result)

    return result
  }

  func dfs(grid: Grid<Character>, visited: inout Set<Coord>, position: Coord, goal: Coord, allowed: (Coord, Character) -> Bool) -> Int? {
    guard position != goal else { return 0 }
    var result = nil as Int?

    for direction in [.up, .right, .down, .left] as [Coord] {
      let newPosition = position + direction

      guard grid.isValid(newPosition) else { continue }
      guard allowed(direction, grid[newPosition]) else { continue }
      guard !visited.contains(newPosition) else { continue }

      visited.insert(newPosition)

      if let count = dfs(grid: grid, visited: &visited, position: newPosition, goal: goal, allowed: allowed) {
        result = max(result ?? 0, count + 1)
      }

      visited.remove(newPosition)
    }

    return result
  }
}

