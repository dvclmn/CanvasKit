//
//  SelectTool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import BasePrimitives
import InteractionKit
import SwiftUI

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
  ) -> ToolResolution? {
    
    let adjustment: InteractionAdjustment = switch context.interaction {
      case .tap(let location): .pointer(.tap(location))
      case .drag(let payload): .pointer(from: payload)
      default: .none
    }

    return .init(
      for: context.interaction,
      adjustment: adjustment,
      action: .none
    )
  }
}
