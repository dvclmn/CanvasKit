//
//  ToolResolution.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 18/3/2026.
//

import Foundation
import InteractionKit

/// The combined result of a tool resolving a pointer interaction.
///
/// Separates canvas-level state changes (`adjustment`) from domain-level
/// actions (`action`) so that `CanvasHandler` can execute the
/// adjustment immediately, while the consuming app handles the action.
public struct ToolResolution: Sendable {
  public let adjustment: InteractionAdjustment
  //  public let transform: TransformAdjustment

  //  public let interaction: Interaction
  //  public let adjustment: CanvasAdjustment
  public let action: ToolAction

  public init(
    adjustment: InteractionAdjustment,
    //    transform: TransformAdjustment,
    //    adjustment: CanvasAdjustment = .none,
    action: ToolAction = .none,
  ) {
    self.adjustment = adjustment
    //    self.transform = transform
    self.action = action
  }

  /// Convenience for returning just a canvas adjustment with no domain action.
  //  public static func canvasAdjustment(_ adjustment: CanvasAdjustment) -> Self {
  //    .init(adjustment: adjustment)
  //  }

  /// Convenience for returning just a domain action with no canvas change.
  //  public static func action(_ action: ToolAction) -> Self {
  //    .init(action: action)
  //  }

  //  public static let none = Self()
}
