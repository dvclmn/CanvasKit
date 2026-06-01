//
//  ZoomTool.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/3/2026.
//

import SwiftUI
private import ViewTools

/// When selected, pointer click-drag zooms (vertical axis).
/// Tap to zoom in, Option+tap to zoom out.
public struct ZoomTool: CanvasTool {
  public let kind: CanvasToolKind = .zoom
  public let name = "Zoom"
  public let icon = "magnifyingglass"

  public init() {}

  public var dragConfiguration: PointerDragConfiguration {
    .init(behaviour: .continuous(axes: .vertical))
  }

  /// Matches drag and tap regardless of modifier state.
  public var inputCapabilities: [ToolCapability] {
    [
      ToolCapability(interaction: .drag, intent: .zoom, modifiers: nil),
      ToolCapability(interaction: .tap, intent: .zoom, modifiers: nil),
    ]
  }

  public func resolvePointerStyle(
    context: InteractionContext
  ) -> PointerStyleCompatible {
    context.modifiers.contains(.option) ? .zoomOut : .zoomIn
  }

  public func resolveInteraction(
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
        case .tap:
          .transform(
            .zoomAdjustment(
              for: currentTransform,
              by: context.modifiers.contains(.option) ? 0.8 : 1.25,
            )
          )

        default: .none  // shouldn't be reached, given capabilities
      }
    return .handled(adjustment)
  }

  private func deltaDrag(
    _ delta: Size<ViewportSpace>,
    modifiers: EventModifiers,
    transform: TransformState,
  ) -> InteractionAdjustment {
    var factor = ZoomComputation.factorFromDelta(
      delta.cgSize,
      weights: .upRight,
    )
    // Hold Option to invert the zoom direction during drag, mirroring tap behaviour.
    if modifiers.contains(.option) {
      factor = 1 / max(factor, 0.0001)
    }
    return .transform(.zoomAdjustment(for: transform, by: factor))
  }

  private func rectDrag(
    from: Point<ViewportSpace>,
    current: Point<ViewportSpace>,
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
