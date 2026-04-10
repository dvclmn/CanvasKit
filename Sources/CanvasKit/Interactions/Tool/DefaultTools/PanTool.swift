//
//  PanTool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import BasePrimitives
import InteractionKit
import SwiftUI

/// When selected, pointer click-drag pans the canvas.
public struct PanTool: CanvasTool {
  public let kind: CanvasToolKind = .pan
  public let name = "Pan"
  public let icon = "hand.raised"

  public var dragBehaviour: PointerDragBehaviour { .continuous }

  public init() {}
}

extension PanTool {

  public func resolvePointerStyle(
    context: InteractionContext
  ) -> PointerStyleCompatible {
    context.isPointerDragging ? .grabActive : .grabIdle
  }

  public func resolvePointerInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution? {

    let interactionKind = context.interaction.kind
    
    let adjustment: TransformAdjustment
    let toolAction
    guard
    switch context.interaction {
      case .drag(let payload):
        switch payload {
          case .delta(let delta, _):
            .init(
              adjustment: .transform(.panAdjustment(for: currentTransform, delta: delta)),
              action: .none,
            )

          case .rect(_, _): .none
        }

      default: .none
    }
  }

}
