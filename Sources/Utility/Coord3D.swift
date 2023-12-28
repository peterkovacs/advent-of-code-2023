//
//  File.swift
//  
//
//  Created by Peter Kovacs on 12/27/23.
//

import Foundation

public struct Coord3: Equatable, Hashable {
  public var x, y, z: Int

  public init(x: Int, y: Int, z: Int) {
    self.x = x
    self.y = y
    self.z = z
  }

  public typealias Direction = (Coord3) -> Coord3
}

extension Coord3 {
  public static var zero: Self { .init(x: 0, y: 0, z: 0) }
}

extension Coord3: Comparable {
  public static func < (lhs: Coord3, rhs: Coord3) -> Bool {
    lhs.z == rhs.z ? (lhs.y == rhs.y ? (lhs.x < rhs.x) : lhs.y < rhs.y) : lhs.z < rhs.z
  }
}

extension Coord3 {
  public enum Plane {
    case xy
    case yz
    case xz
  }
  public func project(_ plane: Plane) -> Coord {
    switch plane {
    case .xy: return .init(x: x, y: y)
    case .yz: return .init(x: y, y: z)
    case .xz: return .init(x: x, y: z)
    }
  }
  public func distance(to: Coord3) -> Int {
    Swift.abs(x - to.x) + Swift.abs(y - to.y) + Swift.abs(z - to.z)
  }

  public static func +(lhs: Self, rhs: Self) -> Self {
    .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
  }

  public static func -(lhs: Self, rhs: Self) -> Self {
    .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
  }

  public static func *(lhs: Self, rhs: Int) -> Self {
    .init(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
  }
}

extension Coord3: CustomStringConvertible {
  public var description: String {
    "(\(x), \(y), \(z))"
  }
}
