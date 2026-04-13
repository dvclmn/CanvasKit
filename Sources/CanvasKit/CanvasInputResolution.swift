//
//  CanvasInputResolution.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/4/2026.
//

import Foundation

enum CanvasInputResolution {
  /// For cases where Tool use is inactive, so just a
  /// basic zoom/pan adjustment is required
  case base(TransformAdjustment)

  /// For when Tools are in use, requiring full input resolution
  case tool(ToolResolution)
}

extension CanvasTool {
  func shouldResolve(
    with context: InteractionContext,
    resolution: ToolResolution,
  ) -> Bool {
    let interaction = context.interaction.kind

    if let adjustment = resolution.adjustment.kind {
      return inputCapabilities.contains { capability in
        capability.matches(
          interaction: interaction,
          adjustment: adjustment,
        )
      }
    }

    guard !resolution.action.isNone else { return false }

    return inputCapabilities.contains { capability in
      capability.interactionKind == interaction
    }
  }
}

/// Whether in Tools mode or not, there will be an adjustment to be made,
/// based on some interaction. So Base should probably not be optional
///
/// Then, if Tools are active, there may also be an adjustment / Tool action

//struct CanvasInputResolution {
//
//  /// The adjustment based on an interaction. Produced
//  /// regardless of whether Tools are in use or not.
//  ///
//  /// Pointer interactions are only active when Tool use is active,
//  /// so this is a `TransformAdjustment` only.
//  let baseAdjustment: TransformAdjustment
//
//  /// A possible Tool resolution, produced only when Tools are in use
//  let toolResolution: ToolResolution?
//}

//enum InputResolutionError: Error, LocalizedError {
//  case invalidInteraction
//
//  var errorDescription: String? {
//    switch self {
//      case .invalidInteraction:
//        <#code#>
//    }
//  }
//}
