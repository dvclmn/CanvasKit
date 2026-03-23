//
//  OnGridDragModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 23/3/2026.
//

import BasePrimitives
import SwiftUI

/// Observes pointer drags and delivers the selected grid cell range.
///
/// Converts the continuous drag rect into the top-left and bottom-right
/// grid positions that the rect spans.
struct OnGridDragModifier: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.gridGeometry) private var gridGeometry

  let action: (GridDragEvent) -> Void

  func body(content: Content) -> some View {
    content
      .onCanvasDrag(in: CanvasSpace.self) { event in
        guard let gridGeometry else { return }

        let projection = gridGeometry.projection
        let rect = event.rect
        let endPoint = Point<CanvasSpace>(x: rect.maxX, y: rect.maxY)

        guard
          let origin = projection.gridPositionIfValid(from: rect.origin),
          let end = projection.gridPositionIfValid(from: endPoint)
        else { return }

        action(.init(start: origin, end: end, phase: event.phase))
      }
  }
}
