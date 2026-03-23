//
//  OnGridDragModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 23/3/2026.
//

import SwiftUI
import BasePrimitives

//public typealias GridDragEvent = (start: GridPosition, end: GridPosition, phase: InteractionPhase)

public struct GridDragEvent {
  let start: GridPosition
  let end: GridPosition
  let phase: InteractionPhase
  
  public init(start: GridPosition, end: GridPosition, phase: InteractionPhase) {
    self.start = start
    self.end = end
    self.phase = phase
  }
}

//extension GridDragEvent {
//  public init() {
//    
//  }
//}

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
      .onCanvasDrag(in: CanvasSpace.self) { canvasRect in
        guard let gridGeometry else { return }
        
        let projection = gridGeometry.projection
        let endPoint = Point<CanvasSpace>(x: canvasRect.maxX, y: canvasRect.maxY)
        
        guard
          let origin = projection.gridPositionIfValid(from: canvasRect.origin),
          let end = projection.gridPositionIfValid(from: endPoint)
        else { return }
        
        action(.init(start: origin, end: end, phase: <#T##InteractionPhase#>))
      }
  }
}

