//
//  PanTool.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/3/2026.
//

import ViewTools
import SwiftUI

/// When selected, pointer click-drag pans the canvas.
public struct PanTool: CanvasTool {
  public let kind: CanvasToolKind = .pan
  public let name = "Pan"
  public let icon = "hand.raised"

  public var dragConfiguration: PointerDragConfiguration {
    .init(behaviour: .continuous(axes: .both), minimumDistance: 0)
  }
  
  public var inputCapabilities: [ToolCapability] {
    [ToolCapability(interaction: .drag, intent: .pan)]
  }

  public init() {}

  public func resolvePointerStyle(
    context: InteractionContext
  ) -> PointerStyleCompatible {
    context.isPointerDragging ? .grabActive : .grabIdle
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
              .transform(.panAdjustment(for: currentTransform, delta: delta))

            case .rect(_, _): .none
          }

        default: .none
      }
    return .handled(adjustment)
  }
}
