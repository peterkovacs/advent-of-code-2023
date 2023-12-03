
import ArgumentParser
import Utility

struct Day3: ParsableCommand {
  func part1(grid: Grid<Character>) -> Int {
    grid.indices.reduce(into: (result: 0, value: 0, isPartNumber: false)) { partialResult, i in
      if grid[i].isNumber {
        partialResult.value *= 10
        partialResult.value += Int(String(grid[i]))!
      } else {
        if partialResult.isPartNumber {
          partialResult.result += partialResult.value
        }
        partialResult.value = 0
        partialResult.isPartNumber = false
      }

      if partialResult.value > 0, grid.neighbors(around: i).contains(where: { !grid[$0].isNumber && grid[$0] != "." }) {
        partialResult.isPartNumber = true
      }
    }.result
  }

  func part2(grid: Grid<Character>) -> Int {
    grid.indices.reduce(into: (value: 0 as Int, isGear: Coord?.none, numbers: [:] as [Coord: [Int]])) { partialResult, i in
      if grid[i].isNumber {
        partialResult.value *= 10
        partialResult.value += Int(String(grid[i]))!
      } else {
        if let gear = partialResult.isGear {
          partialResult.numbers[ gear, default: []].append(partialResult.value)
        }
        partialResult.value = 0
        partialResult.isGear = nil
      }

      if partialResult.value > 0, partialResult.isGear == nil, let gear = grid.neighbors(around: i).first(where: { grid[$0] == "*" }) {
        partialResult.isGear = gear
      }
    }
    .numbers
    .filter { $0.value.count == 2 }
    .map { $0.value[0] * $0.value[1] }
    .reduce(0, +)
  }

  mutating func run() {
    let grid = self.grid

    print("Part 1:", part1(grid: grid))
    print("Part 2:", part2(grid: grid))
  }
}
