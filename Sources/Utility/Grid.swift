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

  public static var zero:  Self { .init(x: 0, y: 0)  }
  public static var right: Self { .init(x: 1, y: 0)  }
  public static var left:  Self { .init(x: -1, y: 0) }
  public static var up:    Self { .init(x: 0, y: -1) }
  public static var down:  Self { .init(x: 0, y: 1)  }
}

extension Coord {
  public var adjacent: [Coord] {
    [up, `left`, down, `right`]
  }

  public var around: [Coord] {
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
    lhs.y == rhs.y ? (lhs.x < rhs.x) : lhs.y < rhs.y
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

  public func applying(_ transform: CGAffineTransform) -> Self {
    guard !transform.isIdentity else { return self }
    let point = CGPoint(x: x, y: y).applying(transform)
    return .init(x: Int(point.x.rounded(.toNearestOrEven)), y: Int(point.y.rounded(.toNearestOrEven)))
  }
}

public struct Grid<Element> {
  var elements: [Element]
  public var size: Coord
  public var bounds: Coord
  public var transform: CGAffineTransform

  public init(
    repeating element: Element,
    size: Coord
  ) {
    self.elements = .init(repeating: element, count: size.x * size.y)
    self.size = size
    self.bounds = size
    self.transform = .identity
  }

  init(
    repeating element: Element,
    size: Coord,
    bounds: Coord,
    transform: CGAffineTransform
  ) {
    self.elements = .init(repeating: element, count: size.x * size.y)
    self.size = size
    self.bounds = bounds
    self.transform = transform
  }

  init<Seq: Sequence>(
    _ input: Seq,
    size: Coord,
    bounds: Coord,
    transform: CGAffineTransform
  ) where Seq.Element == Element {
    self.elements = Array(input)
    self.size = size
    self.bounds = bounds
    self.transform = .identity

    assert(size.x * size.y == elements.count)
  }

  public init<Seq: Sequence>(
    _ input: Seq,
    size: Coord
  ) where Seq.Element == Element {
    self.elements = Array(input)
    self.size = size
    self.bounds = size
    self.transform = .identity

    assert(size.x * size.y == elements.count, "Input provided was not the expected size: \(size): \(size.x * size.y) != \(elements.count)")
  }

  public func isValid(_ coord: Coord) -> Bool {
    let p = coord.applying(transform)
    return p.x < size.x && p.x >= 0 && p.y < size.y && p.y >= 0
  }

  public subscript(_ coord: Coord) -> Element {
    _read {
      let p = coord.applying(transform)
      assert(p.x < size.x && p.x >= 0 && p.y < size.y && p.y >= 0, "coordinate out of bounds")
      yield elements[p.y * size.x + p.x]
    }

    _modify {
      let p = coord.applying(transform)
      yield &elements[p.y * size.x + p.x]
    }
  }

  public var corners: [Coord] {
    [
      .zero,
      size,
      .init(x: 0, y: size.y),
      .init(x: size.x, y: 0)
    ]
  }

  public func neighbors(adjacent coord: Coord) -> [Coord] {
    coord.adjacent.filter(isValid)
  }

  public func neighbors(around coord: Coord) -> [Coord] {
    coord.around.filter(isValid)
  }
}

extension Grid: Sequence {
  public struct CoordinateIterator: Sequence, IteratorProtocol {
    let size: Coord
    var coordinate: Coord

    public mutating func next() -> Coord? {
      if coordinate.x >= size.x { coordinate = .init(x: 0, y: coordinate.y + 1) }
      if coordinate.y >= size.y { return nil }
      defer { coordinate = coordinate.right }

      return coordinate
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
    return CoordinateIterator(size: bounds, coordinate: .zero)
  }

  public func map<U>(_ f: (Element) throws -> U) rethrows -> Grid<U> {
    return try Grid<U>(elements.map(f), size: size, bounds: bounds, transform: transform)
  }

  public func flatMap<U>(_ f: (Element) throws -> U?) rethrows -> Grid<U>? {
    let elements = try self.elements.compactMap(f)
    guard elements.count == self.elements.count else { return nil }
    return Grid<U>(elements, size: size, bounds: bounds, transform: transform)
  }
}

extension Grid {
  public func applying(_ transform: CGAffineTransform, bounds: Coord) -> Self {
    var grid = self
    grid.bounds = bounds
    grid.transform = transform.concatenating(self.transform)
    return grid
  }

  public func scaled(x: CGFloat, y: CGFloat) -> Self {
    applying(
      .identity
        .scaledBy(x: 1/x, y: 1/y)
      // small nudge so that we get the <scale> number of indices at each position.
        .translatedBy(x: -x / 2 + 1 / x, y: -y / 2 + 1 / y),
      bounds: .init(x: Int(CGFloat(bounds.x) * x), y: Int(CGFloat(bounds.y) * y))
    )
  }

  public var rotated: Self {
    applying(
      .identity
        .translatedBy(x: CGFloat(bounds.x) / 2, y: CGFloat(bounds.y) / 2)
        .rotated(by: .pi/2)
        .translatedBy(x: -CGFloat(bounds.y) / 2, y: -CGFloat(bounds.x) / 2 + 1),
      bounds: .init(x: bounds.y, y: bounds.x)
    )
  }

  public var mirrored: Self {
    applying(
      .identity
        .scaledBy(x: -1, y: 1)
        .translatedBy(x: -CGFloat(bounds.x) + 1, y: 0),
      bounds: bounds
    )
  }

  public var flipped: Self {
    applying(
      CGAffineTransform.identity
        .scaledBy(x: 1, y: -1)
        .translatedBy(x: 0, y: -CGFloat(bounds.y) + 1),
      bounds: bounds
    )
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

    for y in 0..<bounds.y {
      for x in 0..<bounds.x {
        result.append(self[.init(x: x, y: y)].description)
      }

      result.append("\n")
    }

    return result
  }
}
