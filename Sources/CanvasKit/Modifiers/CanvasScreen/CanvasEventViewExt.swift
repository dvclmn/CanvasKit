//
//  CanvasEventViewExt.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 23/3/2026.
//

import SwiftUI
import BasePrimitives

extension View {
  // MARK: - Tap
  /// React to pointer taps in the given coordinate space (defaults to canvas-space).
  ///
  /// ```swift
  /// CanvasView(...)
  ///   .onCanvasTap { point in
  ///     selectGlyph(at: point)
  ///   }
  ///
  /// CanvasView(...)
  ///   .onCanvasTap(in: ScreenSpace.self) { point in
  ///     showPopover(at: point)
  ///   }
  /// ```
  public func onCanvasTap<Space: CanvasCoordinateSpace>(
    in space: Space.Type = CanvasSpace.self,
    perform action: @escaping (Point<Space>) -> Void
  ) -> some View {
    self.modifier(OnCanvasTapModifier<Space>(action: action))
  }

  // MARK: - Drag
  /// React to pointer drags in the given coordinate space (defaults to canvas-space).
  /// Fires every frame the drag is active.
  ///
  /// ```swift
  /// CanvasView(...)
  ///   .onCanvasDrag { rect in
  ///     previewSelection(in: rect)
  ///   }
  ///
  /// CanvasView(...)
  ///   .onCanvasDrag(in: ScreenSpace.self) { rect in
  ///     drawOverlay(at: rect)
  ///   }
  /// ```
  public func onCanvasDrag<Space: CanvasCoordinateSpace>(
    in space: Space.Type = CanvasSpace.self,
    perform action: @escaping (CanvasDragEvent<Space>) -> Void
  ) -> some View {
    self.modifier(OnCanvasDragModifier<Space>(action: action))
  }
}
