//
//  SelectTool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import InteractionKit
import SwiftUI
import BasePrimitives

// MARK: - Select Tool

/// The default selection tool. Pointer drag produces a marquee rectangle;
/// taps register tap locations.
public struct SelectTool: CanvasTool {
  public let kind: CanvasToolKind = .select
  public let name = "Select"
  public let icon = "cursorarrow"

  public var dragBehaviour: PointerDragBehaviour { .marquee }

  public init() {}

  public func resolvePointerStyle(
    context: InteractionContext
  ) -> PointerStyleCompatible { .default }

  public func resolvePointerInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    switch context.source {
      case .pointerTapGesture(_, let location):
        return .canvasAdjustment(.updatePointerTap(location))

      case .pointerDragGesture(let payload):
        return .canvasAdjustment(.updatePointerDrag(payload.boundingRect))

      default:
        return .none
    }
  }
}
