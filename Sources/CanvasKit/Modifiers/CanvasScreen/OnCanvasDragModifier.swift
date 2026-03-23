//
//  OnCanvasDragModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 23/3/2026.
//

import BasePrimitives
import SwiftUI

/// Observes pointer drag events and delivers the rect in the requested coordinate space.
struct OnCanvasDragModifier<Space: CanvasCoordinateSpace>: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState

  let action: (CanvasDragEvent<Space>) -> Void

  func body(content: Content) -> some View {
    content
      .onChange(of: interactionState.pointer.drag) { _, newDrag in
        guard
          let screenRect = newDrag,
          let mapper = interactionState.coordinateSpaceMapper
        else { return }

        let rect = Space.convert(screenRect, using: mapper)
        let event = CanvasDragEvent(rect: rect, phase: interactionState.phase)
        action(event)
      }
  }
}

public struct CanvasDragEvent<Space> {
  let rect: Rect<Space>
  let phase: InteractionPhase
}
