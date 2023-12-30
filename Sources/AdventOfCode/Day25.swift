import ArgumentParser
import Parsing
import Algorithms
import Collections

struct Day25: ParsableCommand { 
  enum Parser {
    static let parser = Parse { (component: String, connections: [String]) -> [[String]] in
      connections.map { [$0, component].sorted() }
    } with: {
      Prefix<Substring>(3) { $0.isLetter }.map(.string)
      ": "
      Many {
        Prefix<Substring>(3) { $0.isLetter }.map(.string)
      } separator: {
        Whitespace(.horizontal)
      }
    }
  }

  func run() throws {
    let input = try input.map(Parser.parser.parse).flatMap { $0 }
    var graph = Dictionary(connections: input)

    // Calculate which edges are used most when doing a BFS from random starting points to all other nodes.
    // This is probablistic though, and can sometimes yield the wrong answer.
    let edges = graph.keys.randomSample(count: graph.count / 50).reduce(into: [:] as [String: Int]) { partialResult, start in
      partialResult.merge(
        find(edges: start, graph: graph),
        uniquingKeysWith: +
      )
    }

    let mostUsed = edges.sorted { $0.value < $1.value }.suffix(3).map(\.key).map { $0.split(separator: "-").map(String.init) }
    let counts = count(components: Array(Set(input).subtracting(mostUsed)))
    print("Part 1", counts.reduce(1, *))
  }

  // Count the number of components in each separate graph
  func count(components input: [[String]]) -> [Int] {
    var index: Dictionary<String, Int> = [:]
    var components: [[String]] = []

    for list in input {
      let (a, b) = (index[list[0]], index[list[1]])
      switch (a, b) {
      case let (.some(a), .some(b)) where a != b:
        components[a].append(contentsOf: components[b])
        components[b].forEach {
          index[$0] = a
        }
        components[b].removeAll()
      case (.some, .some):
        // where a == b, nothing to do.
        break
      case let (.some(a), .none):
        components[a].append(list[1])
        index[list[1]] = a
      case let (.none, .some(b)):
        components[b].append(list[0])
        index[list[0]] = b
      case (.none, .none):
        index[list[0]] = components.endIndex
        index[list[1]] = components.endIndex
        components.insert(list, at: components.endIndex)
      }
    }

    return components.map(\.count).filter { $0 > 0 }
  }

  // calculate how often an edge is used as part of the shortest path between two vertices.
  func find(edges start: String, graph: [String: [String]]) -> [String: Int] {
    var q: Deque = [(start, [] as [String], 0)]
    var visited = Set<String>()
    var result = [String: Int]()

    while let (item, edges, steps) = q.popFirst() {
      visited.insert(item)

      for neighbor in graph[item, default: []] where !visited.contains(neighbor) {
        let edge = [neighbor, item].sorted().joined(separator: "-")
        result.merge(edges.map { ($0, 1) }, uniquingKeysWith: +)
        q.append((neighbor, edges + [edge], steps + 1))
      }
    }

    return result
  }
}

extension Dictionary<String, [String]> {
  init(connections: [[String]]) {
    self.init()

    for connection in connections {
      self[connection[0], default: []].append(connection[1])
      self[connection[1], default: []].append(connection[0])
    }
  }
}
