//
//  ActiveInputs.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import EnumMacros
import Foundation

@SetOfOptions<Int>
public struct ActiveInputs: Equatable, Sendable {
  public enum Options: Int, Sendable {
    case swipe
    case pinch
    case pointerHover
    case pointerTap
    case pointerDrag
  }
}
