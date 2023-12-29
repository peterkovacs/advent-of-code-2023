import ArgumentParser
import Parsing
import Utility

/*
 19, 13, 30 @ -2,  1, -2
 18, 19, 22 @ -1, -1, -2
 20, 25, 34 @ -2, -2, -4
 12, 31, 28 @ -1, -2, -1
 20, 19, 15 @  1, -5, -3
*/

struct Day24: ParsableCommand { 
  enum Parser {
    static let coord: some Parsing.Parser<Substring, Coord3> = Parse(Coord3.init(x:y:z:)) {
      Int.parser()
      ","
      Whitespace(1...)
      Int.parser()
      ","
      Whitespace(1...)
      Int.parser()
    }

    static let vector: some Parsing.Parser<Substring, Vector3> = Parse(Vector3.init(position:direction:)) {
      coord
      Whitespace(1...)
      "@"
      Whitespace(1...)
      coord
    }
  }

  func run() throws {
    // let hail = try String(contentsOf: .homeDirectory.appending(component: "Developer/Personal/AdventOfCode2023/day24.txt")).split(separator: "\n").map(Parser.vector.parse)
    let hail = try input.map(Parser.vector.parse)

    // https://en.wikipedia.org/wiki/Line–line_intersection
    let part1 = hail
      .map {
        Vector(position: $0.position.project(.xy), direction: $0.direction.project(.xy))
      }
      .combinations(ofCount: 2)
      .reduce(into: 0) {
        let (a, b) = ($1[0], $1[1])

        let (x1, x2) = (a.position.x, a.position.x + a.direction.x)
        let (y1, y2) = (a.position.y, a.position.y + a.direction.y)
        let (x3, x4) = (b.position.x, b.position.x + b.direction.x)
        let (y3, y4) = (b.position.y, b.position.y + b.direction.y)

        guard ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)) != 0 else { return }
        let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
        let u = ((x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))

        let px = (x1 + t * (x2 - x1))
        let py = (y1 + t * (y2 - y1))

        if t > 0 && u > 0 && (200000000000000...400000000000000).contains(px) && (200000000000000...400000000000000).contains(py) {
          $0 += 1
        }
      }

    print("Part 1", part1)

    // ---


  }
}

