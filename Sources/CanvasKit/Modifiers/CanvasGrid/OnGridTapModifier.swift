//
//  OnGridTapModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 23/3/2026.
//

import SwiftUI
import BasePrimitives

/// Observes pointer taps and delivers the tapped grid cell position.
///
/// This is the grid-layer analogue to `OnCanvasTapModifier`. It converts
/// continuous canvas-space coordinates into a discrete `GridPosition`
/// using the grid geometry from the environment.
struct OnGridTapModifier: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.gridGeometry) private var gridGeometry
  
  let action: (GridPosition) -> Void
  
  func body(content: Content) -> some View {
    content
      .onCanvasTap(in: CanvasSpace.self) { canvasPoint in
        guard let gridGeometry,
              let position = gridGeometry.projection.gridPositionIfValid(from: canvasPoint),
              gridGeometry.dimensions.contains(position: position)
        else { return }
        action(position)
      }
  }
}
