//
//  PanTool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import SwiftUI
import InteractionPrimitives
import GeometryPrimitives

/// When selected, pointer click-drag pans the canvas.
public struct PanTool: CanvasTool {
  public let kind: CanvasToolKind = .pan
  public let name = "Pan"
  public let icon = "hand.raised"
  public let pointerStyle: PointerStyleCompatible = .grabIdle

  public var dragBehaviour: DragBehavior { .continuous }
//  public var inputPolicy: CanvasInputPolicy {
//    .init(dragBehaviour: .continuous)
//  }

  public init() {}

  public func resolvePointerInteraction(
    context: InteractionContext,
    currentTransform: TransformState
  ) -> ToolResolution {

    switch context.source {
      case .pointerDragGesture(let payload):
        switch payload {
          case .delta(let delta, _):
            //            var new = currentTransform
            //            new.translation += delta
            let new = currentTransform.translation + delta
            return .canvasAdjustment(.updateTranslation(new))

          case .rect(_, _):
            print("Not sure if this is right")
            return .none
        }

      default:
        return .none
    }
  }

  public func resolvePointerStyle(
    context: InteractionContext
  ) -> PointerStyleCompatible {
    context.isPointerDragging ? .grabActive : .grabIdle
  }
}
