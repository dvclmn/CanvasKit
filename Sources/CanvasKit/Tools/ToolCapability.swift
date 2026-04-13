//
//  ToolCapability.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

public struct ToolCapability: Hashable, Sendable {
  public let interactionKind: InteractionKind
  public let adjustmentKind: AdjustmentKind

  public init(
    interaction: InteractionKind,
    adjustment: AdjustmentKind,
  ) {
    self.interactionKind = interaction
    self.adjustmentKind = adjustment
  }
}

extension ToolCapability {

  static let swipeToTranslate = Self(interaction: .swipe, adjustment: .translation)
  static let swipeToScale = Self(interaction: .swipe, adjustment: .scale)
  static let pinchToScale = Self(interaction: .pinch, adjustment: .scale)
  static let rotateToRotate = Self(interaction: .rotate, adjustment: .rotation)
  static let tapLocation = Self(interaction: .tap, adjustment: .tapLocation)
  static let tapToScale = Self(interaction: .tap, adjustment: .scale)
  static let dragToTranslate = Self(interaction: .drag, adjustment: .translation)
  static let dragToScale = Self(interaction: .drag, adjustment: .scale)
  static let dragRect = Self(interaction: .drag, adjustment: .dragRect)
  static let hoverLocation = Self(interaction: .hover, adjustment: .hoverLocation)

  /// Canonical canvas gestures that a tool may claim.
  static let canvasBasics: [Self] = [
    .swipeToTranslate,
    .pinchToScale,
    .rotateToRotate,
  ]

  /// Selection-style pointer interactions.
  static let selection: [Self] = [
    .tapLocation,
    .dragRect,
  ]

  /// Pan tool pointer interactions.
  static let pan: [Self] = [
    .dragToTranslate
  ]

  /// Zoom tool pointer interactions.
  static let zoom: [Self] = [
    .tapToScale,
    .dragToScale,
  ]
}

extension ToolCapability {
  func matches(
    interaction: InteractionKind,
    adjustment: AdjustmentKind?,
  ) -> Bool {
    guard interactionKind == interaction, let adjustment else { return false }
    return adjustmentKind == adjustment
  }
}

extension ToolCapability: CustomStringConvertible {
  public var description: String {
    "\(interactionKind.displayName) → \(adjustmentKind.displayName)"
  }
}
