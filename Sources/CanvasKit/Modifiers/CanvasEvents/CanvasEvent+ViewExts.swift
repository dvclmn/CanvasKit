//
//  CanvasEvent+ViewExts.swift
//  CanvasKit
//
//  Created by Dave Coleman on 26/4/2026.
//

import GeometryPrimitives
import SwiftUI

extension View {

  /// Respond to `CanvasView` pointer taps. Provides the
  /// location of the tap in `CanvasSpace`.
  public func onCanvasTap(
    perform action: @escaping (Point<CanvasSpace>) -> Void
  ) -> ModifiedContent<Self, CanvasTapModifier> {
    self.modifier(CanvasTapModifier(action: action))
  }

  /// Respond to a `CanvasView` pointer drag operation.
  /// Provides the rectangle of the drag in `CanvasSpace`,
  /// along with the interaction's phase.
  public func onCanvasDrag(
    perform action: @escaping (CanvasDragEvent<CanvasSpace>) -> Void
  ) -> ModifiedContent<Self, CanvasDragModifier> {
    self.modifier(CanvasDragModifier(action: action))
  }

  /// Respond to a `CanvasView` pointer hover operation.
  public func onCanvasHover(
    perform action: @escaping (Point<CanvasSpace>) -> Void
  ) -> ModifiedContent<Self, CanvasHoverModifier> {
    self.modifier(CanvasHoverModifier(action: action))
  }

}
