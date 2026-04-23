//
//  ZoomTool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//


import GeometryPrimitives
import InputPrimitives
import SwiftUI

/// When selected, pointer click-drag zooms (vertical axis).
/// Tap to zoom in, Option+tap to zoom out.
public struct ZoomTool: CanvasTool {
  public let kind: CanvasToolKind = .zoom
  public let name = "Zoom"
  public let icon = "magnifyingglass"

  public var dragBehaviour: PointerDragBehaviour { .continuous(axes: .vertical) }
  public var inputCapabilities: [ToolCapability] { ToolCapability.zoom }

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
    currentTransform: TransformState,
  ) -> ToolResolution {

    let adjustment: InteractionAdjustment =
      switch context.interaction {
        case .drag(let payload):
          switch payload {
            case .delta(let delta, _):
              deltaDrag(
                delta,
                modifiers: context.modifiers,
                transform: currentTransform,
              )

            case .rect(let from, let current):
              rectDrag(from: from, current: current, transform: currentTransform)

          }

        case .tap(_):
          .transform(
            .zoomAdjustment(
              for: currentTransform,
              by: context.modifiers.isHoldingOption ? 0.8 : 1.25,
            )
          )

        default: .none
      }
    
    return .init(
      for: context.interaction,
      adjustment: adjustment,
      action: .none
    )
  }

  private func deltaDrag(
    _ delta: Size<ScreenSpace>,
    modifiers: Modifiers,
    transform: TransformState,
  ) -> InteractionAdjustment {
    var factor = ZoomComputation.factorFromDelta(
      delta.cgSize,
      weights: .upRight,
    )
    /// Hold Option to invert the zoom direction during drag, mirroring tap behaviour
    if modifiers.contains(.option) {
      factor = 1 / max(factor, 0.0001)
    }
    return .transform(.zoomAdjustment(for: transform, by: factor))
  }

  private func rectDrag(
    from: Point<ScreenSpace>,
    current: Point<ScreenSpace>,
    transform: TransformState,
  ) -> InteractionAdjustment {

    let factor = ZoomComputation.factorFromPoints(
      from: from.cgPoint,
      to: current.cgPoint,
      weights: .upRight,
    )
    return .transform(.zoomAdjustment(for: transform, by: factor))
  }
}
