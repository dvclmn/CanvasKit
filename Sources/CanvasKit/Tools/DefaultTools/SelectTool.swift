//
//  SelectTool.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/3/2026.
//

import SwiftUI

// MARK: - Select Tool

/// The default selection tool. Pointer drag produces a marquee rectangle;
/// taps register tap locations.
public struct SelectTool: CanvasTool {
  public let id: CanvasToolID = .select
  public let name = "Select"
  public let icon = "cursorarrow"

  public var dragConfiguration: PointerDragConfiguration { .marquee }
  public var inputCapabilities: [ToolCapability] {
    [
      ToolCapability(interaction: .tap, intent: .select),
      ToolCapability(interaction: .drag, intent: .drawMarquee),
    ]
  }

  public init() {}

  public func resolvePointerStyle(
    context: InteractionContext
  ) -> CanvasPointerStyle { .default }

  public func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {

    switch context.interaction {
      case .tap(let location):
        return .handled(.pointer(.tap(location)))

      case .drag:
        // CanvasHandler records the richer marquee snapshot independently of
        // tool-owned state mutation. Select consumes the drag so no canvas
        // default is applied.
        return .consumed

      default:
        return .passthrough
    }
  }
}
