import Foundation
import Collections
import XCTest
@testable import Utility

class GridTests: XCTestCase {
  func testIndices() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5))
    print(grid)

    XCTAssertEqual(Array(grid.indices).count, 50)
    XCTAssertEqual(Set(grid.indices).count, 50)

    XCTAssertEqual(grid.indices.map(\.x).min(), 0)
    XCTAssertEqual(grid.indices.map(\.x).max(), 9)

    XCTAssertEqual(grid.indices.map(\.y).min(), 0)
    XCTAssertEqual(grid.indices.map(\.y).max(), 4)
  }

  func testIndices_withScale() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5)).scaled(x: 10, y: 10)
    print(grid)

    XCTAssertEqual(Array(grid.indices).count, 10 * 5 * 10 * 10)
    XCTAssertEqual(Set(grid.indices).count, 5000)

    XCTAssertEqual(grid.indices.map(\.x).min(), 0)
    XCTAssertEqual(grid.indices.map(\.x).max(), 99)

    XCTAssertEqual(grid.indices.map(\.y).min(), 0)
    XCTAssertEqual(grid.indices.map(\.y).max(), 49)
  }

  func testIndices_withRotation() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5)).rotated
    print(grid)

    XCTAssertEqual(Array(grid.indices).count, 10 * 5)
    XCTAssertEqual(Set(grid.indices).count, 10 * 5)

    XCTAssertEqual(grid.indices.map(\.x).min(), 0)
    XCTAssertEqual(grid.indices.map(\.x).max(), 4)

    XCTAssertEqual(grid.indices.map(\.y).min(), 0)
    XCTAssertEqual(grid.indices.map(\.y).max(), 9)
  }

  func testIndices_withDoubleRotation() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5)).rotated.rotated
    print(Array(grid.indices.map { ($0, $0.applying(grid.transform)) }))
    print(grid)

    XCTAssertEqual(Array(grid.indices).count, 10 * 5)
    XCTAssertEqual(Set(grid.indices).count, 10 * 5)

    XCTAssertEqual(grid.indices.map(\.x).min(), 0)
    XCTAssertEqual(grid.indices.map(\.x).max(), 9)

    XCTAssertEqual(grid.indices.map(\.y).min(), 0)
    XCTAssertEqual(grid.indices.map(\.y).max(), 4)
  }

  func testIndices_withTripleRotation() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5)).rotated.rotated.rotated
    print(grid)

    XCTAssertEqual(Array(grid.indices).count, 10 * 5)
    XCTAssertEqual(Set(grid.indices).count, 10 * 5)

    XCTAssertEqual(grid.indices.map(\.x).min(), 0)
    XCTAssertEqual(grid.indices.map(\.x).max(), 4)

    XCTAssertEqual(grid.indices.map(\.y).min(), 0)
    XCTAssertEqual(grid.indices.map(\.y).max(), 9)
  }

  func testIndices_withQuadrupleRotation() throws {
    let orig = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5))
    let grid = orig.rotated.rotated.rotated.rotated

    XCTAssertEqual(grid.description, orig.description)
  }

  func testIndices_withMirror() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5)).mirrored
    print(grid)

    XCTAssertEqual(Array(grid.indices).count, 10 * 5)
    XCTAssertEqual(Set(grid.indices).count, 10 * 5)

    XCTAssertEqual(grid.indices.map(\.x).min(), 0)
    XCTAssertEqual(grid.indices.map(\.x).max(), 9)

    XCTAssertEqual(grid.indices.map(\.y).min(), 0)
    XCTAssertEqual(grid.indices.map(\.y).max(), 4)
  }

  func testIndices_withFlip() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5)).flipped
    print(grid)

    XCTAssertEqual(Array(grid.indices).count, 10 * 5)
    XCTAssertEqual(Set(grid.indices).count, 10 * 5)

    XCTAssertEqual(grid.indices.map(\.x).min(), 0)
    XCTAssertEqual(grid.indices.map(\.x).max(), 9)

    XCTAssertEqual(grid.indices.map(\.y).min(), 0)
    XCTAssertEqual(grid.indices.map(\.y).max(), 4)
  }

}
