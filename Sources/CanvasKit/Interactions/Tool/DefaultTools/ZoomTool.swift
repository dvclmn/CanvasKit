//
//  ZoomTool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import InteractionKit
import SwiftUI
import BasePrimitives

// MARK: - Zoom Tool

/// When selected, pointer click-drag zooms (vertical axis).
/// Tap to zoom in, Option+tap to zoom out.
public struct ZoomTool: CanvasTool {
  public let kind: CanvasToolKind = .zoom
  public let name = "Zoom"
  public let icon = "magnifyingglass"
//  public let pointerStyle: PointerStyleCompatible = .zoomIn

  public var dragBehaviour: PointerDragBehaviour { .continuous(axes: .vertical) }

  public init() {}

  public func resolvePointerStyle(
    context: InteractionContext
  ) -> PointerStyleCompatible {
    context.modifiers.contains(.option) ? .zoomOut : .zoomIn
  }

  public func resolvePointerInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution? {

    switch context.interaction {
      case .drag(let payload):
//      case .pointerDragGesture(let payload):
        switch payload {

          case .delta(let size, _):
            var factor = ZoomComputation.factorFromDelta(
              size.cgSize,
              weights: .upRight,
            )
            /// Hold Option to invert the zoom direction during drag, mirroring tap behaviour
            if context.modifiers.contains(.option) {
              factor = 1 / max(factor, 0.0001)
            }
            
            return .init(
              adjustment: .transform(.zoomAdjustment(for: currentTransform, by: factor)),
              action: .none
            )
//            return .canvasAdjustment(.zoomAdjustment(for: currentTransform, by: factor))

          case .rect(let from, let current):

            let factor = ZoomComputation.factorFromPoints(
              from: from.cgPoint,
              to: current.cgPoint,
              weights: .upRight,
            )
            return .init(
              adjustment: .transform(.zoomAdjustment(for: currentTransform, by: factor)),
              action: .none
            )
//            return .canvasAdjustment(.zoomAdjustment(for: currentTransform, by: factor))
        }

      case .tap(_):
        let step = context.modifiers.contains(.option) ? 0.8 : 1.25
        return .init(
          adjustment: .transform(.zoomAdjustment(for: currentTransform, by: step)),
          action: .none
        )
        
        

      default: return nil
    }
  }
}
