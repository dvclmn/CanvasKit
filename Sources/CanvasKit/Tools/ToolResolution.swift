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

  /// Optional as not every ``Interaction`` always
  /// produces an adjustment
  public let adjustment: InteractionAdjustment
  public let action: ToolAction

  public init?(
    for interaction: Interaction,
    adjustment: InteractionAdjustment,
    action: ToolAction,
  ) {
    guard adjustment.isSupported(by: interaction.kind) else { return nil }
    self.adjustment = adjustment
    self.action = action
  }
}
