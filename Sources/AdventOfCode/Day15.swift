
import ArgumentParser
import Collections
import Parsing

struct Day15: ParsableCommand { 
  enum Parser {
    static let hash = Many(into: 0) { (partialResult: inout Int, i: Substring.UTF8View) in
        partialResult.combine(bytes: i)
    } element: {
      Prefix<Substring.UTF8View>(1...) { $0 != 44 }
    }

    static let hashes = Many(into: 0) {
      $0 += $1
    } element: {
      hash
    } separator: {
      ",".utf8
    } terminator: {
      End()
    }

    enum Instruction {
      case equal(Int)
      case remove
    }

    static let boxes = Many(into: []) { (partialResult: inout [(label: String, box: Int, instruction: Instruction)], value: (Substring.UTF8View, Instruction) ) in
      partialResult.append((String(value.0)!, 0.combine(bytes: value.0), value.1))
    } element: {
      Prefix<Substring.UTF8View>(1...) { (97..<123).contains($0) }

      OneOf {
        Parse(Instruction.equal) {
          "=".utf8
          Int.parser()
        }

        "-".utf8.map { .remove }
      }
    } separator: {
      ",".utf8
    } terminator: {
      End()
    }
  }

  func run() throws {
    let input = stdin
    let part1 = try Parser.hashes.parse(input)
    print("Part 1", part1)

    let instructions = try Parser.boxes.parse(input)
    var boxes = [OrderedDictionary<String, Int>](repeating: .init(), count: 256)
    for instruction in instructions {
      switch instruction.instruction {
      case .equal(let lens):
        boxes[instruction.box][instruction.label] = lens
      case .remove:
        boxes[instruction.box].removeValue(forKey: instruction.label)
      }
    }

    let part2 = zip(1..., boxes)
      .map { box, contents in

        zip(1..., contents)
          .map { slot, lens in
            box * slot * lens.value
          }
          .reduce(0, +)

      }
      .reduce(0, +)

    print("Part 2", part2)
  }
}

extension Int {
  mutating func combine<S: Sequence<UInt8>>(bytes i: S) {
    for value in i {
      self = ((self + Int(value)) * 17) % 256
    }
  }

  @_disfavoredOverload
  func combine<S: Sequence<UInt8>>(bytes: S) -> Int {
    var value = self
    value.combine(bytes: bytes)
    return value
  }
}
