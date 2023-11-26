import Foundation

public struct InfiniteGrid<Element> {
  var elements: [Coord: Element]
  var defaultElement: (Coord) -> Element
  public var origin: Coord
  public var size: Coord

  fileprivate init(
    elements: [Coord: Element],
    defaultElement: @escaping (Coord) -> Element,
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
    self.defaultElement = { _ in element }
    self.elements = [:]
  }

  public init<Seq: Sequence>(
    _ input: Seq,
    size: Coord,
    default: @escaping (Coord) -> Element
  ) where Seq.Element == Element {
    self.origin = .zero
    self.size = size
    self.defaultElement = `default`

    self.elements =  Dictionary(
      uniqueKeysWithValues: zip(
        Grid<Element>.CoordinateIterator(
          size: size,
          transform: .identity,
          coordinate: .zero
        ),
        input
      )
    )

    precondition(size.x * size.y == elements.count)
  }

  public subscript(_ coord: Coord) -> Element {
    _read {
      yield elements[coord] ?? defaultElement(coord)
    }

    _modify {
      origin.x = Swift.min(origin.x, coord.x)
      origin.y = Swift.min(origin.y, coord.y)
      size.x   = Swift.max(size.x,   coord.x+1)
      size.y   = Swift.max(size.y,   coord.y+1)

      yield &elements[coord, default: defaultElement(coord)]
    }
  }

  func neighbors(adjacent coord: Coord) -> [Coord] {
    coord.adjacent
  }

  func neighbors(around coord: Coord) -> [Coord] {
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

  func map<U>(_ f: @escaping (Element) -> U) -> InfiniteGrid<U> {
    .init(
      elements: elements.mapValues(f),
      defaultElement: { f(defaultElement($0)) },
      origin: origin,
      size: size
    )
  }

  func flatMap<U>(default: @escaping @autoclosure () -> U, _ f: @escaping (Element) -> U?) -> InfiniteGrid<U>? {
    let elements = self.elements.compactMapValues(f)
    guard elements.count == self.elements.count else { return nil }

    return .init(
      elements: elements,
      defaultElement: { f(defaultElement($0)) ?? `default`() },
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
        let c = Coord(x: x, y: y)
        // result.append(c.description)
        result.append(self[c].description)
      }

      result.append("\n")
    }

    return result
  }
}
