//
//  InteractionSource.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 16/3/2026.
//

import BasePrimitives
import SwiftUI

/// Previously called `InteractionSource`
public enum Interaction: Sendable {
  case swipe(delta: Size<ScreenSpace>)  // onSwipeGesture
  case pinch(scale: Double)  // onPinchGesture
  case rotation(angle: Angle)  // Not yet supported
  case tap(location: Point<ScreenSpace>)  // onTapGesture
  case drag(PointerDragPayload)  // onPointerDragGesture
  case hover(Point<ScreenSpace>)  // onContinuousHover
}

extension Interaction {
  var kind: InteractionKind {
    switch self {
      case .swipe: .swipe
      case .pinch: .pinch
      case .rotation: .rotation
      case .tap: .tap
      case .drag: .drag
      case .hover: .hover
    }
  }
}

extension Interaction: CustomStringConvertible {
  public var description: String {
    switch self {
      case .swipe(let delta): "Swipe delta: \(delta)"
      case .pinch(let scale): "Pinch scale: \(scale)"
      case .rotation(let angle): "Rotation angle: \(angle)"
      case .tap(let location): "Tap at: \(location)"
      case .drag(let pointerDragPayload): "Drag: \(pointerDragPayload)"
      case .hover(let point): "Hover location: \(point)"
    }
  }
}

public enum PointerButton: String, Sendable {
  case primary
  case secondary
  case middle
}
