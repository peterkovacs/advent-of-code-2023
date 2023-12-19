
import ArgumentParser
import Parsing
import Collections

struct Day19: ParsableCommand {
  enum Destination {
    case rejected
    case accepted
    case workflow(String)

    static let parser = Parse {
      OneOf {
        "R".map { Self.rejected }
        "A".map { Self.accepted }
        Prefix<Substring> { $0.isLetter }
          .map(.string)
          .map(Self.workflow)
      }
    }
  }

  enum Part1 {
    struct Part {
      let x, m, a, s: Int
      var value: Int { x + m + a + s }

      static let parser = Parse(.memberwise(Part.init(x:m:a:s:))) {
        "{x="
        Int.parser()
        ",m="
        Int.parser()
        ",a="
        Int.parser()
        ",s="
        Int.parser()
        "}"
      }
    }

    struct Workflow {
      let comparisons: [Rule]
      let `default`: Destination

      func apply(_ part: Part) -> Destination {
        comparisons.first { $0.isApplicable(to: part) }?.destination ?? `default`
      }
    }

    struct Rule {
      let keyPath: KeyPath<Part, Int>
      let comparison: (Int, Int) -> Bool
      let value: Int
      let destination: Destination

      func isApplicable(to part: Part) -> Bool {
        comparison( part[keyPath: keyPath], value )
      }

      static let parser = Parse(Rule.init) {
        OneOf {
          "x".map { \Part.x }
          "m".map { \.m }
          "a".map { \.a }
          "s".map { \.s }
        }

        OneOf {
          ">".map { { $0 > $1 } as (Int, Int) -> Bool}
          "<".map { { $0 < $1 } as (Int, Int) -> Bool}
        }

        Int.parser()
        ":"
        Destination.parser
      }
    }

    enum Parser {

      static let workflow = Parse {
        Prefix<Substring> { $0.isLetter }.map(.string)
        "{"
        Parse(Workflow.init) {
          Many(1...) { Rule.parser } separator: { "," }
          ","
          Destination.parser
        }
        "}"
      }

      static let parser = Parse {
        Many(1..., into: [String: Workflow]()) {
          $0[$1.0] = $1.1
        } element: {
          workflow
        } separator: {
          Whitespace(1, .vertical)
        } terminator: {
          Whitespace(2, .vertical)
        }

        Many {
          Part.parser
        } separator: {
          Whitespace(1, .vertical)
        } terminator: {
          Whitespace(0...1, .vertical)
          End()
        }
      }
    }
  }

  enum Part2 {
    struct Part: CustomStringConvertible {
      var x, m, a, s: Range<Int>
      var value: Int { x.count * m.count * a.count * s.count }

      var description: String {
        "{x:\(x.lowerBound)...\(x.upperBound-1), m:\(m.lowerBound)...\(m.upperBound-1) a:\(a.lowerBound)...\(a.upperBound-1) s:\(s.lowerBound)...\(s.upperBound-1)}"
      }
    }

    struct Rule {
      let keyPath: WritableKeyPath<Part, Range<Int>>
      let comparison: (Range<Int>, Int) -> (Range<Int>, Range<Int>)
      let value: Int
      let destination: Destination

      func apply(to part: Part) -> (Range<Int>, Range<Int>) {
        comparison( part[keyPath: keyPath], value )
      }

      static let parser = Parse(Self.init) {
        OneOf {
          "x".map { \Part.x }
          "m".map { \.m }
          "a".map { \.a }
          "s".map { \.s }
        }

        OneOf {
          ">".map { { $0.split(greaterThan: $1) } as (Range<Int>, Int) -> (Range<Int>, Range<Int>) }
          "<".map { { $0.split(lessThan: $1) } as (Range<Int>, Int) -> (Range<Int>, Range<Int>) }
        }

        Int.parser()
        ":"
        Destination.parser
      }
    }

    struct Workflow {
      let comparisons: [Rule]
      let `default`: Destination

      func apply(to part: Part) -> (accepted: Int, next: [(Part, String)]) {
        var accepted = 0
        var result = [(Part, String)]()
        var part = part

        for comparison in comparisons {
          let (yes, no) = comparison.apply(to: part)

          if !yes.isEmpty {
            part[keyPath: comparison.keyPath] = yes
            switch comparison.destination {
            case .accepted: accepted += part.value
            case .rejected: break
            case .workflow(let next): result.append((part, next))
            }
          }

          part[keyPath: comparison.keyPath] = no
        }

        switch `default` {
        case .accepted: accepted += part.value
        case .rejected: break
        case .workflow(let next): result.append((part, next))
        }

        return (accepted, result)
      }
    }

    enum Parser {

      static let workflow = Parse {
        Prefix<Substring> { $0.isLetter }.map(.string)
        "{"
        Parse(Workflow.init) {
          Many(1...) { Rule.parser } separator: { "," }
          ","
          Destination.parser
        }
        "}"
      }

      static let parser = Parse {
        Many(1..., into: [String: Workflow]()) {
          $0[$1.0] = $1.1
        } element: {
          workflow
        } separator: {
          Whitespace(1, .vertical)
        } terminator: {
          Whitespace(2, .vertical)
        }

        Skip { Rest() }
      }
    }
  }

  func run() throws {
    let input = stdin
    do {
      let (workflow, parts) = try Part1.Parser.parser.parse(input)
      let part1 = parts.filter {
        workflow.isAccepted(location: "in", part: $0)
      }.map(\.value).reduce(0, +)
      print("Part 1", part1)
    }

    do {
      let workflow = try Part2.Parser.parser.parse(input)
      let part2 = workflow.count(location: "in", part: .init(x: 1..<4001, m: 1..<4001, a: 1..<4001, s: 1..<4001))
      print("Part 2", part2)
    }
  }
}

extension Dictionary where Key == String, Value == Day19.Part1.Workflow {
  func isAccepted(location: String, part: Day19.Part1.Part) -> Bool {
    switch self[location]!.apply(part) {
    case .accepted: return true
    case .rejected: return false
    case .workflow(let next): return isAccepted(location: next, part: part)
    }
  }
}

extension Dictionary where Key == String, Value == Day19.Part2.Workflow {
  func count(location: String, part: Day19.Part2.Part) -> Int {
    let (accepted, next) = self[location]!.apply(to: part)
    return next.reduce(accepted) { $0 + count(location: $1.1, part: $1.0) }
  }
}

fileprivate extension Range<Int> {
  func split(lessThan element: Int) -> (Range<Int>, Range<Int>) {
    if contains(element) {
      return (self[..<element], self[element...])
    } else if element > upperBound {
      return (self, 0..<0)
    } else {
      return (0..<0, self)
    }
  }

  func split(greaterThan element: Int) -> (Range<Int>, Range<Int>) {
    if contains(element) {
      return (self[(element+1)...], self[...element])
    } else if element > upperBound {
      return (0..<0, self)
    } else {
      return (self, 0..<0)
    }
  }

}
