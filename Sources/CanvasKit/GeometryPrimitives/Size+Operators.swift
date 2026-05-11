//
//  Size+Operators.swift
//  BasePrimitives
//
//  Created by Dave Coleman on 4/4/2026.
//

import Foundation

public func += <Space>(lhs: inout Size<Space>, rhs: Size<Space>) {
  lhs.width += rhs.width
  lhs.height += rhs.height
}

public func += <Space>(lhs: inout Size<Space>, rhs: CGFloat) {
  lhs.width += rhs
  lhs.height += rhs
}

public func + <Space>(
  lhs: Size<Space>,
  rhs: Size<Space>,
) -> Size<Space> {
  Size<Space>(
    width: lhs.width + rhs.width,
    height: lhs.height + rhs.height,
  )
}

public func * <Space, T: BinaryFloatingPoint>(lhs: Size<Space>, rhs: T) -> Size<Space> {
  let s = CGFloat(rhs)
  return Size<Space>(
    width: lhs.width * s,
    height: lhs.height * s,
  )
}

public func / <Space, T: BinaryFloatingPoint>(lhs: Size<Space>, rhs: T) -> Size<Space> {
  let s = CGFloat(rhs)
  return Size<Space>(
    width: lhs.width / s,
    height: lhs.height / s,
  )
}

public func *= <Space, T: BinaryFloatingPoint>(lhs: inout Size<Space>, rhs: T) {
  let s = CGFloat(rhs)
  lhs.width *= s
  lhs.height *= s
}

public func /= <Space, T: BinaryFloatingPoint>(lhs: inout Size<Space>, rhs: T) {
  let s = CGFloat(rhs)
  lhs.width /= s
  lhs.height /= s
}
