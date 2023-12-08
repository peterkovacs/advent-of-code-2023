//
//  File.swift
//  
//
//  Created by Peter Kovacs on 12/8/23.
//

import Foundation

public func gcd(_ x: Int, _ y: Int) -> Int {
    var a = 0
    var b = max(x, y)
    var r = min(x, y)

    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

/*
 Returns the least common multiple of two numbers.
 */
public func lcm(_ x: Int, _ y: Int) -> Int {
    return x / gcd(x, y) * y
}
