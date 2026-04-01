//
//  PanTool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import GeometryPrimitives
import InteractionPrimitives
import SwiftUI

/// When selected, pointer click-drag pans the canvas.
public struct PanTool: CanvasTool {
  public let kind: CanvasToolKind = .pan
  public let name = "Pan"
  public let icon = "hand.raised"
  public let pointerStyle: PointerStyleCompatible = .grabIdle

  public var dragBehaviour: DragBehavior { .continuous }

  public init() {}

  public func resolvePointerStyle(
    context: InteractionContext
  ) -> PointerStyleCompatible {
    context.isPointerDragging ? .grabActive : .grabIdle
  }

  public func resolvePointerInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {

    switch context.source {
      case .pointerDragGesture(let payload):
        switch payload {
          case .delta(let delta, _):
            return .canvasAdjustment(.panAdjustment(for: currentTransform, delta: delta))

          case .rect(_, _):
            print("Not sure if this is right?")
            return .none
        }

      default:
        return .none
    }
  }

}
