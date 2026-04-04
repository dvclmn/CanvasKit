//
//  InteractionStateModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import InteractionKit
import SwiftUI

/// Bundles up the necessary parts for callers to initialise state
/// outside of CanvasView. This should be placed as high up the
/// hierarchy as is needed for access.
struct InteractionStateSetupModifier: ViewModifier {
  @Environment(\.modifierKeys) private var modifierKeys
  @State private var interactionState: CanvasInteractionState = .init()

  @Binding var toolHandler: ToolHandler
  let canvasSize: Size<CanvasSpace>

  func body(content: Content) -> some View {
    content
      .environment(interactionState)

//      .setSnapshotValues(
//        interactionState.snapshot(in: canvasSize)
//      )
      .environment(\.zoomLevel, interactionState.transform.scale)
      .environment(\.panOffset, interactionState.transform.translation.cgSize)
      .environment(\.rotation, interactionState.transform.rotation)
          .environment(\.pointerLocation, snapshot?.pointerLocation?.cgPoint)

      .environment(\.pointerStyle, interactionState.pointerStyle)

      .task(id: modifierKeys) {
        toolHandler.updateModifiers(modifierKeys)
      }

      .environment(\.activeTool, toolHandler.effectiveTool)
    
//      .environment(\.coordinateSpaceMapper, interactionState.coordinateSpaceMapper)

      //      .syncEnvironment(\.activeTool) { interactionState.activeTool = $0 }
      //      .syncEnvironment(\.activeTool, to: $interactionState.activeTool)
      /// Watches tool kind rather than the tool itself, as `any CanvasTool`
      /// can't conform to Equatable
      .task(id: toolHandler.effectiveTool.kind) {
        interactionState.updateTool(to: toolHandler.effectiveTool)
      }

      /// Provides interaction state with updated zoom range
      .syncEnvironment(\.zoomRange) { interactionState.updateZoomRange(to: $0) }
      
//      .syncEnvironment(\.activeTool, using: \.?.kind, apply: <#T##(Value) -> Void#>)
//      .syncEnvironment(\.activeTool, using: \.kind, to: $interactionState.activeTool)
  }
}

extension InteractionStateSetupModifier {
  private func snapshot(
    in canvasSize: Size<CanvasSpace>,
    //    mapper: CoordinateSpaceMapper,
  ) -> CanvasSnapshot? {
    guard let hover = pointer.hover else { return nil }
    let hoverMapped = mapper.canvasPoint(from: hover)
    let isInside = mapper.isInsideCanvas(hoverMapped, in: canvasSize)
    
    return CanvasSnapshot(
      pointerLocation: hoverMapped,
      isPointerInsideCanvas: isInside,
      zoom: transform.scale,
      pan: transform.translation.cgSize,
      rotation: transform.rotation,
    )
  }
}
