//
//  CanvasAdjustment.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import SwiftUI
import InteractionPrimitives
import GeometryPrimitives

/// The output of a tool's `resolve()` method.
///
/// These are **canvas-level state mutations** only — things that
/// `CanvasInteractionState` knows how to execute. Domain-level
/// outputs (e.g. "place a shape", "commit a stroke") go through
/// `ToolAction` instead.
///
/// Note: Could consider either wrapping up pointer state just like
/// `updateTransform` is, or breaking out `updateTransform`
/// into three like these pointer cases
public enum CanvasAdjustment: Sendable {

  /// Replace the entire transform state (pan, zoom, rotation).
  case updateTranslation(Size<ScreenSpace>)
  case updateScale(Double)
  case updateRotation(Angle)

  /// Update the pointer drag rectangle (e.g. marquee selection,
  /// or a tool-driven drag region).
  case updatePointerDrag(Rect<ScreenSpace>?)

  /// Update the pointer tap location.
  case updatePointerTap(Point<ScreenSpace>?)
  case updatePointerHover(Point<ScreenSpace>?)

  /// No canvas state change needed.
  case none
}

extension CanvasAdjustment {
  public static func zoomAdjustment(
    for transform: TransformState,
    by factor: CGFloat,
  ) -> Self {
    let new = transform.scale * factor
    return .updateScale(new)
//    return .init(adjustment: .updateScale(new), action: .none)
  }
}
