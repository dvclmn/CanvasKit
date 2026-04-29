//
//  ToolResolution.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 18/3/2026.
//

import Foundation

// TODO: Should this really be ToolCapabilityResolution?
public enum ToolResolution: Sendable {
  
  /// The tool has handled this interaction. Apply the adjustment,
  /// which may be "none", which is valid
  case handled(InteractionAdjustment)
  
  /// The tool does not claim this interaction. Fall through to canvas defaults.
  case passthrough
}

/// The combined result of a tool resolving a pointer interaction.
///
/// Separates canvas-level state changes (`adjustment`) from domain-level
/// actions (`action`) so that `CanvasHandler` can execute the
/// adjustment immediately, while the consuming app handles the action.
//public struct ToolResolution: Sendable {
//
//  /// While support/usage is kinda murky at this stage, Tools may declare both
//  /// a Pointer *and* a Transform adjustment in response to an Interaction
//  let adjustment: InteractionAdjustment
//
//  @available(*, message: "A very early work-in-progress, not stable enough for any kind of use yet.")
//  let action: ToolAction
//
//  init(
//    adjustment: InteractionAdjustment,
//    action: ToolAction,
//  ) {
//    self.adjustment = adjustment
//    self.action = action
//  }
//
//  public static let none: Self = .init(
//    adjustment: .none,
//    action: .none,
//  )
//}
//
//extension ToolResolution {
//  init(
//    for interaction: Interaction,
//    adjustment: InteractionAdjustment,
//    action: ToolAction,
//  ) {
//    if adjustment.isSupported(by: interaction.kind) {
//      self.init(adjustment: adjustment, action: action)
//    } else {
//      print("Adjustment \(adjustment) not supported by \(interaction.kind.displayName)")
//      self = .none
//    }
//  }
//}
