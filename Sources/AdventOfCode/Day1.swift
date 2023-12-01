import ArgumentParser
import Foundation
import Utility
import RegexBuilder

struct Day1: ParsableCommand {
  func run() throws {
    let lines = Array(input)
    let part1 = lines.map {
      let digits = $0.matches(of: #/\d/#).map(\.output)
      return Int(digits[0] + digits[ digits.count - 1 ])!
    }.reduce(0, +)

    print("Part 1", part1)

    let map = [
      "one": 1,
      "two": 2,
      "three": 3,
      "four": 4,
      "five": 5,
      "six": 6,
      "seven": 7,
      "eight": 8,
      "nine": 9
    ]

    let forwardsRegex = try! Regex("([1-9]|\(map.keys.joined(separator: "|")))")
    let reversedRegex = try! Regex("([1-9]|\(map.keys.map{ String($0.reversed()) }.joined(separator: "|")))")

    let part2 = lines.compactMap { line in
      guard
        let firstDigit = line.firstMatch(of: forwardsRegex)?.output
          .extractValues(as: (Substring, Substring).self)
          .flatMap({ Int(String($0.1)) ?? map[String($0.1)] }),

          let lastDigit = Substring(line.reversed()).firstMatch(of: reversedRegex)?.output
          .extractValues(as: (Substring, Substring).self)
          .flatMap({ Int(String($0.1)) ?? map[String($0.1.reversed())] })
      else {
        return nil
      }

      return firstDigit * 10 + lastDigit
    }.reduce(0, +)

    print("Part 2", part2)
  }
}

