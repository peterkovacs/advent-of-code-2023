
import ArgumentParser
import Utility

struct Day11: ParsableCommand { 
  func run() {
    let grid = self.grid
    let galaxies = grid.indices.filter { grid[$0] == "#" }
    let emptyRows = Set(0..<grid.size.y).subtracting(galaxies.map(\.y))
    let emptyCols = Set(0..<grid.size.y).subtracting(galaxies.map(\.x))

    func calculate(multiplier: Int) -> Int {
      galaxies.combinations(ofCount: 2).reduce(0) {
        let (a, b) = ($1[0], $1[1])
        return $0 + a.distance(to: b) +
          (a.y < b.y ? a.y..<b.y : b.y..<a.y).reduce(0) { $0 + (emptyRows.contains($1) ? multiplier : 0) } as Int +
          (a.x < b.x ? a.x..<b.x : b.x..<a.x).reduce(0) { $0 + (emptyCols.contains($1) ? multiplier : 0) } as Int
      }
    }

    let part1 = calculate(multiplier: 1)
    print("Part 1", part1)
    let part2 = calculate(multiplier: 1_000_000 - 1)
    print("Part 2", part2)
  }
}
