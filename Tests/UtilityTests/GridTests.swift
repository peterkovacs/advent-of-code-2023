import Foundation
import Collections
import XCTest
@testable import Utility

class GridTests: XCTestCase {
  func testNeighborsAround() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5))
    XCTAssertEqual(grid.neighbors(around: .zero), [.init(x: 0, y: 1), .init(x: 1, y: 1), .init(x: 1, y: 0)])
    XCTAssertEqual(grid.neighbors(around: .init(x: 3, y: 3)), [.init(x: 4, y: 2), .init(x: 3, y: 2), .init(x: 2, y: 2), .init(x: 2, y: 3), .init(x: 2, y: 4), .init(x: 3, y: 4), .init(x: 4, y: 4), .init(x: 4, y: 3)])
    XCTAssertEqual(grid.neighbors(around: .init(x: 9, y: 4)), [.init(x: 9, y: 3), .init(x: 8, y: 3), .init(x: 8, y: 4)])
  }

  func testNeighborsAround_withRotation() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5)).rotated
    XCTAssertEqual(grid.neighbors(around: .zero), [.init(x: 0, y: 1), .init(x: 1, y: 1), .init(x: 1, y: 0)])
    XCTAssertEqual(grid.neighbors(around: .init(x: 3, y: 3)), [.init(x: 4, y: 2), .init(x: 3, y: 2), .init(x: 2, y: 2), .init(x: 2, y: 3), .init(x: 2, y: 4), .init(x: 3, y: 4), .init(x: 4, y: 4), .init(x: 4, y: 3)])
    XCTAssertEqual(grid.neighbors(around: .init(x: 4, y: 9)), [.init(x: 4, y: 8), .init(x: 3, y: 8), .init(x: 3, y: 9)])
  }

  func testNeighborsAround_withScale() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5)).scaled(x: 10, y: 10)
    XCTAssertEqual(grid.neighbors(around: .zero), [.init(x: 0, y: 1), .init(x: 1, y: 1), .init(x: 1, y: 0)])
    XCTAssertEqual(grid.neighbors(around: .init(x: 30, y: 30)), [.init(x: 31, y: 29), .init(x: 30, y: 29), .init(x: 29, y: 29), .init(x: 29, y: 30), .init(x: 29, y: 31), .init(x: 30, y: 31), .init(x: 31, y: 31), .init(x: 31, y: 30)])
    XCTAssertEqual(grid.neighbors(around: .init(x: 99, y: 49)), [.init(x: 99, y: 48), .init(x: 98, y: 48), .init(x: 98, y: 49)])
  }

  func testNeighborsAdjacent() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5))
    XCTAssertEqual(grid.neighbors(adjacent: .zero), [.init(x: 0, y: 1), .init(x: 1, y: 0)])
    XCTAssertEqual(grid.neighbors(adjacent: .init(x: 3, y: 3)), [.init(x: 3, y: 2), .init(x: 2, y: 3), .init(x: 3, y: 4), .init(x: 4, y: 3)])
    XCTAssertEqual(grid.neighbors(adjacent: .init(x: 9, y: 4)), [.init(x: 9, y: 3), .init(x: 8, y: 4)])
  }

  func testNeighborsAdjacent_withRotation() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5)).rotated
    XCTAssertEqual(grid.neighbors(adjacent: .zero), [.init(x: 0, y: 1), .init(x: 1, y: 0)])
    XCTAssertEqual(grid.neighbors(adjacent: .init(x: 3, y: 3)), [.init(x: 3, y: 2), .init(x: 2, y: 3), .init(x: 3, y: 4), .init(x: 4, y: 3)])
    XCTAssertEqual(grid.neighbors(adjacent: .init(x: 4, y: 9)), [.init(x: 4, y: 8), .init(x: 3, y: 9)])
  }

  func testNeighborsAdjacent_withScale() throws {
    let grid = Grid("abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXY", size: .init(x: 10, y: 5)).scaled(x: 10, y: 10)
    XCTAssertEqual(grid.neighbors(adjacent: .zero), [.init(x: 0, y: 1), .init(x: 1, y: 0)])
    XCTAssertEqual(grid.neighbors(adjacent: .init(x: 30, y: 30)), [.init(x: 30, y: 29), .init(x: 29, y: 30), .init(x: 30, y: 31), .init(x: 31, y: 30)])
    XCTAssertEqual(grid.neighbors(adjacent: .init(x: 99, y: 49)), [.init(x: 99, y: 48), .init(x: 98, y: 49)])
  }


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
