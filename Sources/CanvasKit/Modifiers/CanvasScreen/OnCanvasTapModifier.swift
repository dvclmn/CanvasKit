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
