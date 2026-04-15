//
//  ToolResolution.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 18/3/2026.
//

import Foundation

/// The combined result of a tool resolving a pointer interaction.
///
/// Separates canvas-level state changes (`adjustment`) from domain-level
/// actions (`action`) so that `CanvasHandler` can execute the
/// adjustment immediately, while the consuming app handles the action.
struct ToolResolution: Sendable {

  /// While support/usage is kinda murky at this stage, Tools may declare both
  /// a Pointer *and* a Transform adjustment in response to an Interaction
  let adjustment: InteractionAdjustment
  let action: ToolAction

  init(
    adjustment: InteractionAdjustment,
    action: ToolAction,
  ) {
    self.adjustment = adjustment
    self.action = action
  }

  public static let none: Self = .init(
    adjustment: .none,
    action: .none,
  )
}

extension ToolResolution {
  init(
    for interaction: Interaction,
    adjustment: InteractionAdjustment,
    action: ToolAction,
  ) {
    if adjustment.isSupported(by: interaction.kind) {
      self.init(adjustment: adjustment, action: action)
    } else {
      print("Adjustment \(adjustment) not supported by \(interaction.kind.displayName)")
      self = .none
    }
  }
}
