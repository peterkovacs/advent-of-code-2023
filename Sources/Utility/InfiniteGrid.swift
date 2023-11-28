import Foundation
import CoreGraphics

public struct InfiniteGrid<Element> {
  var elements: [Coord: Element]
  var defaultElement: Element
  public var origin: Coord
  public var size: Coord

  fileprivate init(
    elements: [Coord: Element],
    defaultElement: Element,
    origin: Coord,
    size: Coord
  ) {
    self.elements = elements
    self.defaultElement = defaultElement
    self.origin = origin
    self.size = size
  }

  public init(
    repeating element: Element,
    size: Coord
  ) {
    self.origin = .zero
    self.size = size
    self.defaultElement = element
    self.elements = [:]
  }

  public init<Seq: Sequence>(
    _ input: Seq,
    size: Coord,
    default: Element
  ) where Seq.Element == Element, Element: Equatable {
    self.origin = .zero
    self.size = size
    self.defaultElement = `default`

    self.elements =  Dictionary(
      uniqueKeysWithValues: zip(
        Grid<Element>.CoordinateIterator(
          size: size,
          coordinate: .zero
        ),
        input
      ).filter {
        $0.1 != `default`
      }
    )
  }

  public subscript(_ coord: Coord) -> Element {
    _read {
      yield elements[coord] ?? defaultElement
    }

    _modify {
      origin.x = Swift.min(origin.x, coord.x)
      origin.y = Swift.min(origin.y, coord.y)
      size.x   = Swift.max(size.x,   coord.x+1)
      size.y   = Swift.max(size.y,   coord.y+1)

      yield &elements[coord, default: defaultElement]
    }
  }

  public func neighbors(adjacent coord: Coord) -> [Coord] {
    coord.adjacent
  }

  public func neighbors(around coord: Coord) -> [Coord] {
    coord.around
  }
}

extension InfiniteGrid: Sequence {
  public struct CoordinateIterator: Sequence, IteratorProtocol {
    let origin: Coord
    let size: Coord
    var coordinate: Coord

    public mutating func next() -> Coord? {
      if coordinate.x >= size.x { coordinate = .init(x: origin.x, y: coordinate.y + 1) }
      if coordinate.y >= size.y { return nil }

      defer { coordinate = coordinate.right }

      return coordinate
    }
  }

  public struct Iterator: IteratorProtocol {
    let grid: InfiniteGrid
    var iterator: CoordinateIterator

    public mutating func next() -> Element? {
      guard let coordinate = iterator.next() else { return nil }
      return grid[coordinate]
    }
  }

  public var indices: CoordinateIterator {
    return .init(origin: origin, size: size, coordinate: origin)
  }

  public func makeIterator() -> Iterator {
    .init(grid: self, iterator: indices)
  }

  public func map<U>(_ f: (Element) -> U) -> InfiniteGrid<U> {
    .init(
      elements: elements.mapValues(f),
      defaultElement: f(defaultElement),
      origin: origin,
      size: size
    )
  }

  public func flatMap<U>(_ f: (Element) -> U?) -> InfiniteGrid<U>? {
    let elements = self.elements.compactMapValues(f)
    guard elements.count == self.elements.count else { return nil }

    return .init(
      elements: elements,
      defaultElement: f(defaultElement)!,
      origin: origin,
      size: size
    )
  }
}


extension InfiniteGrid: CustomStringConvertible where Element: CustomStringConvertible {
  public var description: String {
    var result = ""

    for y in origin.y..<size.y {
      for x in origin.x..<size.x {
        result.append(self[.init(x: x, y: y)].description)
      }

      result.append("\n")
    }

    return result
  }
}
