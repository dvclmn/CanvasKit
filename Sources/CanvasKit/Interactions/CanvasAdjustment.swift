//
//  CanvasAdjustment.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import GeometryPrimitives
import InteractionPrimitives
import SwiftUI

/// These are **canvas-level state mutations** only — things that
/// `CanvasInteractionState` knows how to execute. Domain-level
/// outputs (e.g. "place a shape", "commit a stroke") go through
/// `ToolAction` instead.
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
  }
  
  public static func panAdjustment(
    for transform: TransformState,
    delta: Size<ScreenSpace>,
//    by delta: CGSize
  ) -> Self {
    let new = transform.translation + delta
    return .updateTranslation(new)
//    return .canvasAdjustment(.updateTranslation(new))
//    .updateTranslation(delta.toGridCount(for: transform))
  }
}
