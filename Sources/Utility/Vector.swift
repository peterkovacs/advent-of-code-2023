//
//  File.swift
//  
//
//  Created by Peter Kovacs on 12/17/23.
//

import Foundation

public struct Vector: Hashable {
  public var position: Coord
  public var direction: Coord

  public init(position: Coord, direction: Coord) {
    self.position = position
    self.direction = direction
  }

  public func abs() -> Self {
    var result = self
    result.direction = direction.abs()
    return result
  }
}

public struct Vector3: Hashable {
  public var position: Coord3
  public var direction: Coord3

  public init(position: Coord3, direction: Coord3) {
    self.position = position
    self.direction = direction
  }
}
