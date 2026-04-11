//
//  ToolAction.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 18/3/2026.
//

import Foundation

/// Domain-level actions that tools can produce alongside canvas-level adjustments.
///
/// While `CanvasAdjustment` handles canvas state mutations (transform, pointer state),
/// `ToolAction` represents higher-level domain actions that the consuming app
/// is responsible for interpreting.
///
/// For example, a Select tool might produce `.selectAt(point)`, while a
/// drawing tool might produce `.commitStroke(points)`. CanvasKit doesn't
/// know what these mean — it just passes them through to the app's handler.
///
/// Usage:
/// ```swift
/// extension ToolAction {
///   static func selectAt(_ point: Point<CanvasSpace>) -> ToolAction {
///     .custom("selectAt", payload: point)
///   }
/// }
/// ```
public enum ToolAction: Sendable {
  /// A domain-specific action identified by name, with an optional payload.
  case custom(String, payload: (any Sendable)? = nil)

  /// No domain action.
  case none
}

