import Algorithms
import CoreGraphics
import Foundation
import Numerics

public struct Coord: Equatable, Hashable {
  public var x, y: Int

  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  public typealias Direction = (Coord) -> Coord
}

extension Coord {
  public var right: Coord { self + .right }
  public var left: Coord  { self + .left  }
  public var up: Coord    { self + .up    }
  public var down: Coord  { self + .down  }

  static var zero:  Self { .init(x: 0, y: 0)  }
  static var right: Self { .init(x: 1, y: 0)  }
  static var left:  Self { .init(x: -1, y: 0) }
  static var up:    Self { .init(x: 0, y: -1) }
  static var down:  Self { .init(x: 0, y: 1)  }
}

extension Coord {
  var adjacent: [Coord] {
    [up, `left`, down, `right`]
  }

  var around: [Coord] {
    [
      `right`.up, up,
      `left`.up, `left`,
      `left`.down, down,
      `right`.down, `right`
    ]
  }
}

extension Coord: Comparable {
  public static func < (lhs: Coord, rhs: Coord) -> Bool {
    (lhs.x < rhs.x && lhs.y < rhs.y)
  }

  public func distance(to: Coord) -> Int {
    abs(x - to.x) + abs(y - to.y)
  }

  public static func +(lhs: Self, rhs: Self) -> Self {
    .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  public static func -(lhs: Self, rhs: Self) -> Self {
    .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }

  public static func *(lhs: Self, rhs: Int) -> Self {
    .init(x: lhs.x * rhs, y: lhs.y * rhs)
  }

  public var counterClockwise: Self {
    applying(.init(rotationAngle: .pi * 3 / 2))
  }

  public var clockwise: Self {
    applying(.init(rotationAngle: .pi / 2))
  }

  func applying(_ transform: CGAffineTransform) -> Self {
    guard !transform.isIdentity else { return self }
    let point = CGPoint(x: x, y: y).applying(transform)
    return .init(x: Int(point.x.rounded()), y: Int(point.y.rounded()))
  }
}

public struct Grid<Element> {
  var elements: [Element]
  public let size: Coord
  public let transform: CGAffineTransform

  public init(
    repeating element: Element,
    size: Coord,
    transform: CGAffineTransform = .identity
  ) {
    self.elements = .init(repeating: element, count: size.x * size.y)
    self.size = size
    self.transform = transform
  }

  public init<Seq: Sequence>(
    _ input: Seq,
    size: Coord,
    transform: CGAffineTransform = .identity
  ) where Seq.Element == Element {
    self.elements = Array(input)
    self.size = size
    self.transform = transform

    precondition(size.x * size.y == elements.count)
  }

  public subscript(_ coord: Coord) -> Element {
    _read {
      let p = coord.applying(transform)
      yield elements[ p.y * size.x + p.x ]
    }

    _modify {
      let p = coord.applying(transform)
      yield &elements[p.y * size.x + p.x]
    }
  }

  func neighbors(adjacent coord: Coord) -> [Coord] {
    coord.adjacent.filter {
      $0.x >= 0 && $0.x < size.x &&
      $0.y >= 0 && $0.y < size.y
    }
  }

  func neighbors(around coord: Coord) -> [Coord] {
    coord.around.filter {
      $0.x >= 0 && $0.x < size.x &&
      $0.y >= 0 && $0.y < size.y
    }
  }
}

extension Grid: Sequence {
  public struct CoordinateIterator: Sequence, IteratorProtocol {
    let size: Coord
    let transform: CGAffineTransform
    var coordinate: Coord

    public mutating func next() -> Coord? {
      if coordinate.x >= size.x { coordinate = .init(x: 0, y: coordinate.y + 1) }
      if coordinate.y >= size.y { return nil }
      defer { coordinate = coordinate.right }

      return coordinate.applying(transform)
    }
  }

  public struct Iterator: IteratorProtocol {
    let grid: Grid
    var iterator: CoordinateIterator

    public mutating func next() -> Element? {
      guard let coordinate = iterator.next() else { return nil }
      return grid[ coordinate ]
    }
  }

  public func makeIterator() -> Iterator {
    .init(grid: self, iterator: indices)
  }

  public var indices: CoordinateIterator {
    return CoordinateIterator(size: size, transform: transform, coordinate: .zero)
  }

  func map<U>(_ f: (Element) throws -> U) rethrows -> Grid<U> {
    return try Grid<U>(elements.map(f), size: size, transform: transform)
  }

  func flatMap<U>(_ f: (Element) throws -> U?) rethrows -> Grid<U>? {
    let elements = try self.elements.compactMap(f)
    guard elements.count == self.elements.count else { return nil }
    return Grid<U>(elements, size: size, transform: transform)
  }

}

extension Grid: Equatable where Element: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    guard lhs.size == rhs.size else { return false }
    return lhs.elementsEqual(rhs)
  }
}

extension Coord: CustomStringConvertible {
  public var description: String {
    "(\(x), \(y))"
  }
}

extension Grid: CustomStringConvertible where Element: CustomStringConvertible {
  public var description: String {
    var result = ""

    for y in 0..<size.y {
      for x in 0..<size.x {
        result.append(self[.init(x: x, y: y)].description)
      }

      result.append("\n")
    }

    return result
  }
}
