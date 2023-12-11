
import ArgumentParser
import Utility

struct Day11: ParsableCommand { 
  func run() {
    let grid = self.grid
    let galaxies = grid.indices.filter { grid[$0] == "#" }
    let emptyRows = Set(0..<grid.size.y).subtracting(galaxies.map(\.y)).sorted()
    let emptyCols = Set(0..<grid.size.y).subtracting(galaxies.map(\.x)).sorted()

    func calculate() -> (Int, Int) {
      galaxies.combinations(ofCount: 2).reduce((0, 0)) {
        let (a, b) = ($1[0], $1[1])
        let x = a.x < b.x ? a.x..<b.x : b.x..<a.x
        let y = a.y < b.y ? a.y..<b.y : b.y..<a.y

        let rows = emptyRows.drop { $0 < y.lowerBound }.prefix { $0 < y.upperBound }.count
        let cols = emptyCols.drop { $0 < x.lowerBound }.prefix { $0 < x.upperBound }.count

        return (
          $0.0 + a.distance(to: b),
          $0.1 + rows + cols
        )
      }
    }

    let (distance, crossings) = calculate()
    print("Part 1", distance + crossings)
    print("Part 2", distance + (crossings * 999_999))
  }
}
