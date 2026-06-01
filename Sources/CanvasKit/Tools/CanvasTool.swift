//
//  CanvasTool.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/3/2026.
//

private import CoreTools
import SwiftUI
private import ViewTools

/// A canvas tool defines how selected interactions are interpreted.
///
/// CanvasKit applies default behaviour for unclaimed interactions, while tools
/// may opt into specific ``InteractionKind`` values through ``inputCapabilities``.
public protocol CanvasTool: Sendable, Equatable, CustomStringConvertible, Identifiable
where ID == CanvasToolKind {

  /// The tool's identity, used for keyboard binding lookups and registry.
  var kind: CanvasToolKind { get }

  /// Display name for toolbar UI.
  var name: String { get }

  /// SF Symbol name for toolbar UI.
  var icon: String { get }

  /// The drag input policy active when this tool is selected.
  var dragConfiguration: PointerDragConfiguration { get }

  /// The interaction kinds this tool can resolve.
  var inputCapabilities: [ToolCapability] { get }

  /// Resolve the pointer style for the current interaction context.
  func resolvePointerStyle(context: InteractionContext) -> PointerStyleCompatible

  /// Resolves an interaction into a canvas adjustment.
  ///
  /// Only called for sources the tool opted into via `inputCapabilities`.
  /// Return `.passthrough` to let CanvasKit fall back to its default behaviour.
  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution
}

extension CanvasTool {
  public var id: CanvasToolKind { kind }

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
