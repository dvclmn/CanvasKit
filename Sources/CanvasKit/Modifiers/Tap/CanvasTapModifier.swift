//
//  CanvasTapModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import BasePrimitives
import SwiftUI

/// Observes pointer tap events and delivers them in the requested coordinate space.
struct OnCanvasTapModifier<Space: CanvasCoordinateSpace>: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState

  let action: (Point<Space>) -> Void

  func body(content: Content) -> some View {
    content
      .onChange(of: interactionState.pointer.tap) { _, newTap in
        guard
          let screenPoint = newTap,
          let mapper = interactionState.coordinateSpaceMapper
        else { return }
        action(Space.convert(screenPoint, using: mapper))
      }
  }
}

extension View {

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
}
