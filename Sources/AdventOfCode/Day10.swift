
import ArgumentParser
import Utility

/*
 | is a vertical pipe connecting north and south.
 - is a horizontal pipe connecting east and west.
 L is a 90-degree bend connecting north and east.
 J is a 90-degree bend connecting north and west.
 7 is a 90-degree bend connecting south and west.
 F is a 90-degree bend connecting south and east.
*/

/*
 https://web.archive.org/web/20130126163405/http://geomalgorithms.com/a03-_inclusion.html
 Edge Crossing Rules
 - an upward edge includes its starting endpoint, and excludes its final endpoint;
 - a downward edge excludes its starting endpoint, and includes its final endpoint;
 - horizontal edges are excluded
 - the edge-ray intersection point must be strictly right of the point P.
*/

struct Day10: ParsableCommand {
  func run() throws {
    let grid = self.grid
    var windings = Grid(repeating: 0, size: grid.size)
    let start = grid.indices.first { grid[$0] == "S" }!
    var (position, direction, steps, inLoop) = (start, Coord.down, 0, Set<Coord>())

    repeat {
      inLoop.insert(position)
      position = position + direction
      steps += 1

      switch (direction, grid[position]) {
      //  - an upward edge includes its starting endpoint, and excludes its final endpoint;
      case (.up, "7"): direction = direction.counterClockwise
      case (.up, "F"): direction = direction.clockwise
      case (.up, "|"): windings[position] = 1

      case (.down, "L"): 
        direction = direction.counterClockwise
        // - a downward edge excludes its starting endpoint, and includes its final endpoint;
        windings[position] = -1
      case (.down, "J"):
        direction = direction.clockwise
        // - a downward edge excludes its starting endpoint, and includes its final endpoint;
        windings[position] = -1
      case (.down, "|"): 
        windings[position] = -1

      case (.left, "F"): 
        direction = direction.counterClockwise
        // - a downward edge excludes its starting endpoint, and includes its final endpoint;

      case (.left, "L"):
        direction = direction.clockwise
        //  - an upward edge includes its starting endpoint, and excludes its final endpoint;
        windings[position] = 1

      case (.right, "J"): 
        direction = direction.counterClockwise
        //  - an upward edge includes its starting endpoint, and excludes its final endpoint;
        windings[position] = 1

      case (.right, "7"): 
        direction = direction.clockwise
        // - a downward edge excludes its starting endpoint, and includes its final endpoint;

      default: break
      }
    } while position != start

    print("Part 1", steps / 2)

    var inside = 0
    let emptyPoints = grid.indices.filter { !inLoop.contains($0) }

    for point in emptyPoints {

      var p = point.right
      var wn = 0
      while grid.isValid(p) {
        wn += windings[p]
        p = p.right
      }

      if wn != 0 {
        inside += 1
      }
    }

    print("Part 2", inside)
  }
}
