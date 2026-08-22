//
//  CanvasTool.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/3/2026.
//

private import CoreTools
import SwiftUI

/// A canvas tool defines how selected interactions are interpreted.
///
/// CanvasKit applies default behaviour for unclaimed interactions, while tools
/// may opt into specific ``Interaction.Kind`` values through ``inputCapabilities``.
public protocol CanvasTool: Sendable, Equatable, CustomStringConvertible, Identifiable
where ID == CanvasToolID {

  /// The tool's identity, used for keyboard binding lookups and registry.
  var id: CanvasToolID { get }

  /// Display name for toolbar UI.
  var name: String { get }

  /// SF Symbol name for toolbar UI.
  var icon: String { get }

  /// The drag input policy active when this tool is selected.
  var dragConfiguration: PointerDragConfiguration { get }

  /// The physical interactions, semantic intents, and modifier requirements
  /// this tool can resolve.
  var inputCapabilities: [ToolCapability] { get }

  /// Resolve the pointer style for the current interaction context.
  func resolvePointerStyle(context: InteractionContext) -> CanvasPointerStyle

  /// Resolves an interaction into a canvas adjustment.
  ///
  /// Only called after CanvasKit selects a capability from
  /// ``inputCapabilities``. The selected declaration is available through
  /// ``InteractionContext/matchedCapability`` and its semantic meaning through
  /// ``InteractionContext/intent``.
  ///
  /// Return ``ToolResolution/consumed`` to claim input without a CanvasKit-owned
  /// mutation, or ``ToolResolution/passthrough`` to allow a canvas default.
  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution
}

extension CanvasTool {
  public var description: String {
    """
    Name: \(name)
    Capabilities: \(inputCapabilities)
    """
  }
}

extension CanvasTool where Self == SelectTool {
  public static var `default`: any CanvasTool { SelectTool() }
}

extension Array where Element == (any CanvasTool) {
  public static var defaultTools: Self {
    [SelectTool(), PanTool(), ZoomTool()]
  }
}
