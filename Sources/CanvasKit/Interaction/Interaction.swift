//
//  InteractionSource.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 16/3/2026.
//

import SwiftUI
import InteractionKit

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
  public var kind: InteractionKinds {
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

public enum PointerButton: String, Sendable {
  case primary
  case secondary
  case middle
}
