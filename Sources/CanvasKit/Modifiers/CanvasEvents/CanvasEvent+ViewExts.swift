//
//  CanvasEvent+ViewExts.swift
//  CanvasKit
//
//  Created by Dave Coleman on 26/4/2026.
//

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
  ///
  /// Provides ordered anchor/current locations in `CanvasSpace` and a truthful
  /// lifecycle phase. The first update is `.began`, subsequent movement is
  /// `.changed`, normal release is `.ended`, and CanvasKit invalidation is
  /// `.cancelled`.
  public func onCanvasDrag(
    perform action: @escaping (CanvasDragEvent) -> Void
  ) -> ModifiedContent<Self, CanvasDragModifier> {
    self.modifier(CanvasDragModifier(action: action))
  }

  /// Respond to a `CanvasView` pointer hover operation.
  ///
  /// Hover observation remains active for every tool. A tool may claim hover
  /// for specialised resolution without suppressing this callback. The
  /// callback receives `.ended` when the pointer leaves the canvas.
  public func onCanvasHover(
    perform action: @escaping (CanvasHoverPhase) -> Void
      //    perform action: @escaping (Point<CanvasSpace>) -> Void
  ) -> ModifiedContent<Self, CanvasHoverModifier> {
    self.modifier(CanvasHoverModifier(action: action))
  }
}
