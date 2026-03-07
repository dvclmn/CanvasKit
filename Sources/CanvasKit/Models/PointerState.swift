//
//  PointerState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 7/3/2026.
//

import BasePrimitives
import GestureKit

extension CanvasState {
  public struct PointerState: Sendable, Equatable {
    var pointerTap: TapState = .init()
    var pointerDrag: DragState = .init()
    var pointerHover: HoverState = .init()
  }
}

extension CanvasState.PointerState {
  public static let initial: Self = .init()
}
