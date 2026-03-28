//
//  PointerState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 7/3/2026.
//

import CoreGraphics
import Foundation
import InteractionPrimitives

/// Not sure if this could/should be different, but have chosen to
/// use CGPoint for tap and hover, as these stay(?) or are at least
/// captured in screen space. I dunno, just less annoying to work
/// with as CGPoint for now.
public struct PointerState: Sendable, Equatable {
  public var tap: Point<ScreenSpace>?
  public var hover: Point<ScreenSpace>?
  public var drag: Rect<ScreenSpace>?

  public let dragThreshold: CGFloat = 6

  public init() {}
}

extension PointerState {
  public static let initial = PointerState()
}
