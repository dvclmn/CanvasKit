//
//  CanvasEventViewExt.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 23/3/2026.
//

import InteractionKit
import SwiftUI

extension View {

  /// Respond to `CanvasView` pointer taps. Provides the
  /// location of the tap in `CanvasSpace`.
  public func onCanvasTap(
    perform action: @escaping (Point<CanvasSpace>) -> Void
  ) -> some View {
    self.modifier(CanvasTapModifier(action: action))
  }

  /// Respond to a `CanvasView` pointer drag operation.
  /// Provides the rectangle of the drag in `CanvasSpace`,
  /// along with the interaction's phase.
  public func onCanvasDrag(
    perform action: @escaping (CanvasDragEvent<CanvasSpace>) -> Void
  ) -> some View {
    self.modifier(CanvasDragModifier(action: action))
  }
}
