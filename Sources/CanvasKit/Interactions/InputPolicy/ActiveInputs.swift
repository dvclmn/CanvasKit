//
//  ActiveInputs.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import EnumMacros
import Foundation

//@SetOfOptions<Int>
//public struct ActiveInputs: Equatable, Sendable {
//  public enum Options: Int, Sendable {
//    case swipe
//    case pinch
//    case pointerHover
//    case pointerTap
//    case pointerDrag
//  }
//}

public struct ActiveInputs: OptionSet, Sendable {
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  public let rawValue: Int
  
  public static let swipe = Self(rawValue: 1 << 0)
  public static let pinch = Self(rawValue: 1 << 1)
  public static let pointerHover = Self(rawValue: 1 << 2)
  public static let pointerTap = Self(rawValue: 1 << 3)
  public static let pointerDrag = Self(rawValue: 1 << 4)
  public static let all: Self = [
    .swipe,
    .pinch,
    .pointerHover,
    .pointerTap,
    .pointerDrag
  ]
}
