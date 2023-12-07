
import ArgumentParser
import Parsing

struct Day7: ParsableCommand { 
  static let order = Array("__23456789TJQKA")

  enum HandType: Comparable {
    case five
    case four
    case full
    case three
    case twoPair
    case pair
    case none

    static func <(l: Self, r: Self) -> Bool {
      switch (l, r) {
      case (.five, .five): return false
      case (.five, _): return false
      case (_, .five): return true
      case (.four, .four): return false
      case (.four, _): return false
      case (_, .four): return true
      case (.full, .full): return false
      case (.full, _): return false
      case (_, .full): return true
      case (.three, .three): return false
      case (.three, _): return false
      case (_, .three): return true
      case (.twoPair, .twoPair): return false
      case (.twoPair, _): return false
      case (_, .twoPair): return true
      case (.pair, .pair): return false
      case (.pair, _): return false
      case (_, .pair): return true
      case (.none, .none): return false
      case (.none, _): return false
      case (_, .none): return true
      }
    }
  }

  struct Hand: Comparable {
    let cards: [Int]
    let type: HandType
    let bid: Int

    init(cards: [Int], bid: Int) {
      self.cards = cards
      self.bid = bid
      self.type = Self.calculate(type: Dictionary(grouping: cards) { $0 }.mapValues(\.count))
    }

    init(cards: [Int], bid: Int, type: HandType) {
      self.cards = cards
      self.bid = bid
      self.type = type
    }

    private static func calculate(type aggregated: [Int: Int]) -> HandType {
      aggregated.reduce(into: .none) { partialResult, i in
        switch (i.value, partialResult) {
        case (5, _): partialResult = .five
        case (4, _): partialResult = .four
        case (3, .pair): partialResult = .full
        case (3, _): partialResult = .three
        case (2, .three): partialResult = .full
        case (2, .pair): partialResult = .twoPair
        case (2, .none): partialResult = .pair
        case (_, _): break
        }
      }
    }

    func wild() -> Self {
      let cards = self.cards.map { $0 == 11 ? 1 : $0 }
      var aggregated = Dictionary(grouping: cards) { $0 }.mapValues(\.count)
      if let jokers = aggregated[1] {
        if jokers == 5 {
          return .init(cards: cards, bid: bid, type: .five)
        }

        // assume that if there's more than 1 joker, we should just change it to whatever cards are the highest number
        aggregated[1] = nil
        aggregated[aggregated.max { $0.value < $1.value }!.key, default: 0] += jokers
        return .init(cards: cards, bid: bid, type: Self.calculate(type: aggregated))
      }

      return self
    }

    static func <(l: Self, r: Self) -> Bool {
      if l.type == r.type {
        guard let firstNonEqualCard = Array(zip(l.cards, r.cards).drop {  $0 == $1  }.prefix(1)).first else { return false }
        return firstNonEqualCard.0 < firstNonEqualCard.1
      } else {
        return l.type < r.type
      }
    }

    static let parser = Parse { (cards: Substring, bid: Int) in
      Hand(cards: cards.map { Day7.order.firstIndex(of: $0)! }, bid: bid)
    } with: {
      Prefix<Substring>(5)
      Whitespace()
      Int.parser()
    }

  }


  mutating func run() throws {
    let hands = try input.map(Hand.parser.parse).sorted()

    let part1 = hands.enumerated().reduce(0) {
      $0 + ($1.offset + 1) * $1.element.bid
    }

    print("Part 1", part1)

    let part2 = hands.map { $0.wild() }.sorted().enumerated().reduce(0) {
      $0 + ($1.offset + 1) * $1.element.bid
    }

    print("Part 2", part2)
  }
}
