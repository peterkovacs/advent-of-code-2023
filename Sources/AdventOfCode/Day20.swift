import ArgumentParser
import Parsing
import Collections
import Utility

protocol Pulseable {
  typealias Output = (input: String, output: String, pulse: Day20.Pulse)

  var name: String { get }
  var inputs: [String] { get }
  var destinations: [String] { get set }
  mutating func pulse(input: String, pulse: Day20.Pulse) -> [Output]
  mutating func add(input: String)
}

struct Day20: ParsableCommand {
  enum Pulse {
    case low, high
  }

  struct Untyped: Pulseable {
    
    var name: String
    var destinations: [String] = []
    var count: [Int] = [0, 0]
    var inputs: [String] = []
    mutating func add(input: String) {
      inputs.append(input)
    }

    mutating func pulse(input: String, pulse: Day20.Pulse) -> [Output] {
      count[pulse == .low ? 0 : 1] += 1
      return []
    }
  }

  struct FlipFlop: Pulseable {
    var name: String
    var state: Bool = false
    var destinations: [String]
    var inputs: [String] = []
    mutating func add(input: String) {
      inputs.append(input)
    }


    mutating func pulse(input: String, pulse: Day20.Pulse) -> [Output] {
      switch pulse {
      case .high: return []
      case .low:
        state.toggle()
        return destinations.map { (name, $0, state ? .high : .low) }
      }
    }
  }

  struct Conjunction: Pulseable {
    var name: String
    var memory: [String: Pulse] = .init()
    var destinations: [String]

    var inputs: [String] { Array(memory.keys) }

    mutating func add(input: String) {
      memory[input] = .low
    }

    mutating func pulse(input: String, pulse: Day20.Pulse) -> [Output] {
      memory[input] = pulse

      if memory.values.allSatisfy({ $0 == .high }) {
        return destinations.map { (name, $0, .low) }
      } else {
        return destinations.map { (name, $0, .high) }
      }
    }
  }

  struct Broadcast: Pulseable {
    var name: String = "broadcaster"
    var destinations: [String]
    var inputs: [String] = []
    mutating func add(input: String) {
      inputs.append(input)
    }


    func pulse(input: String, pulse: Day20.Pulse) -> [Output] {
      return destinations.map { (name, $0, pulse) }
    }
  }

  enum Parser {
    static let destinations = Parse {
      " -> "
      Many {
        Prefix { $0.isLetter }.map(.string)
      } separator: {
        ", "
      }
    }

    static let module = OneOf {
      Parse {
        ($0, FlipFlop(name: $0, destinations: $1) as any Pulseable)
      } with: {
        "%"
        Prefix { $0.isLetter }.map(.string)
        destinations
      }

      Parse {
        ($0, Conjunction(name: $0, destinations: $1) as any Pulseable)
      } with: {
        "&"
        Prefix { $0.isLetter }.map(.string)
        destinations
      }

      Parse {
        ("broadcaster", Broadcast(destinations: $0))
      } with: {
        "broadcaster"
        destinations
      }
    }
  }

  func run() throws {
    var modules = Dictionary(uniqueKeysWithValues: try input.map { try Parser.module.parse($0) })
    modules["rx"] = Untyped(name: "rx")

    for module in modules {
      for (key, value) in modules where value.destinations.contains(where: { $0 == module.key }) {
        modules[module.key, default: Untyped(name: module.key)].add(input: key)
      }
    }

    do {
      var part1 = modules
      let counts = part1.pushButton(times: 1000)
      print("Part 1", counts[0] * counts[1])
    }

    do {
      // based on the fact that the input to "rx" is a Conjunction with 4 inputs.
      // we need all of the conjunction's inputs to output a high at the same time.
      // Therefore, we count how many pushes it takes for each one to receive a high,
      // and the answer is the lcm.
      let rx = modules["rx"]!
      assert(rx.inputs.count == 1)
      assert(modules[rx.inputs[0]]! is Conjunction)
      let targets = Set(modules[rx.inputs[0]]!.inputs)

      var part2 = modules
      let count = part2.count(until: targets, outputs: .high)
      print("Part 2", count)
    }
  }
}

extension Dictionary where Key == String, Value == Pulseable {
  mutating func pushButton(times: Int) -> [Int] {
    var outputs = Deque<Pulseable.Output>()
    var counts = [0, 0]

    for _ in 0..<times {
      counts[0] += 1
      outputs.append(contentsOf: self["broadcaster"]!.pulse(input: "button", pulse: .low))
      while let (input, output, pulse) = outputs.popFirst() {
        counts[ pulse == .low ? 0 : 1 ] += 1
        outputs.append(contentsOf:  self[output, default: Day20.Untyped(name: output)].pulse(input: input, pulse: pulse))
      }
    }

    return counts
  }

  mutating func count(until target: Set<String>, outputs sends: Day20.Pulse) -> Int {
    var outputs = Deque<Pulseable.Output>()
    var target = target
    var result = 1

    for pushes in 1... {

      outputs.append(contentsOf: self["broadcaster"]!.pulse(input: "button", pulse: .low))
      while let (input, output, pulse) = outputs.popFirst() {
        let next = self[output, default: Day20.Untyped(name: output)].pulse(input: input, pulse: pulse)

        if !next.isEmpty, next[0].pulse == sends, target.remove(output) != nil {
          result = lcm(result, pushes)

          if target.isEmpty { return result }
        }

        outputs.append(contentsOf: next)
      }
    }

    fatalError()
  }

}
