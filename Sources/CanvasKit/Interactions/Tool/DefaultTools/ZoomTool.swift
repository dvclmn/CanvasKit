//
//  ZoomTool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import SwiftUI
import InteractionPrimitives

// MARK: - Zoom Tool

/// When selected, pointer click-drag zooms (vertical axis).
/// Tap to zoom in, Option+tap to zoom out.
public struct ZoomTool: CanvasTool {
  public let kind: CanvasToolKind = .zoom
  public let name = "Zoom"
  public let icon = "magnifyingglass"
  public let pointerStyle: PointerStyleCompatible = .zoomIn

  public var inputPolicy: CanvasInputPolicy {
    .init(dragBehaviour: .continuous(axes: .vertical))
  }

  public init() {}
}

extension ZoomTool {

  public func resolvePointerStyle(
    context: InteractionContext
  ) -> PointerStyleCompatible {
    context.modifiers.contains(.option) ? .zoomOut : .zoomIn
  }

  public func resolvePointerInteraction(
    context: InteractionContext,
    currentTransform: TransformState
  ) -> ToolResolution {
    switch context.source {
      case .pointerDragGesture(let payload):
        return handlePointerDrag(
          payload,
          modifiers: context.modifiers,
          currentTransform: currentTransform
        )

      case .pointerTapGesture(_, _):
        let step = context.modifiers.contains(.option) ? 0.8 : 1.25
        return .zoomAdjustment(for: currentTransform, by: step)
      //        return adjustedZoom(currentTransform, by: step)

      default:
        return .none
    }
  }

}

extension ZoomTool {
  private func handlePointerDrag(
    _ payload: PointerDragPayload,
    modifiers: Modifiers,
    currentTransform: TransformState
  ) -> ToolResolution {

    switch payload {

      case .delta(let size, _):
        var factor = ZoomComputation.factorFromDelta(
          size.cgSize,
          weights: .upRight
        )
        /// Hold Option to invert the zoom direction during drag, mirroring tap behavior
        if modifiers.contains(.option) {
          factor = 1 / max(factor, 0.0001)
        }
        return .zoomAdjustment(for: currentTransform, by: factor)
      //        return adjustedZoom(currentTransform, by: factor)
      //        let new = currentTransform.scale * factor
      //        return .canvasAdjustment(.updateScale(new))

      case .rect(let from, let current):

        let factor = ZoomComputation.factorFromPoints(
          from: from.cgPoint,
          to: current.cgPoint,
          weights: .upRight
        )

        //        let new = currentTransform.scale * factor
        //        return .canvasAdjustment(.updateScale(new))
        return .zoomAdjustment(for: currentTransform, by: factor)
    }
  }
}
