//
//  CanvasTool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import BasePrimitives
import InteractionKit
import SwiftUI

/// A canvas tool defines how pointer interactions (tap, drag) are interpreted.
///
/// Global gestures (swipe→pan, pinch→zoom) are handled centrally
/// by `CanvasHandler` and never reach `resolvePointerInteraction()`.
/// Tools only receive pointer events: taps and drags. This may change in future, not sure yet
public protocol CanvasTool: Sendable, Equatable, Identifiable where ID == CanvasToolKind {

  /// The tool's identity, used for keyboard binding lookups and registry.
  var kind: CanvasToolKind { get }

  /// Display name for toolbar UI.
  var name: String { get }

  /// SF Symbol name for toolbar UI.
  var icon: String { get }

  /// The drag input policy active when this tool is selected.
  var dragBehaviour: PointerDragBehaviour { get }

  /// Resolve the pointer style for the current interaction context.
  func resolvePointerStyle(context: InteractionContext) -> PointerStyleCompatible

  /// Resolve an interaction into a canvas adjustment and optional domain action.
  ///
  /// Only called for sources the tool opted into via `inputCapabilities`.
  /// Global gestures are still handled separately before this is reached.
  ///
  /// This allows a Tool to declare what should happen when it is selected,
  /// and certain interaction events happen
  func resolvePointerInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution?
}

extension CanvasTool {
  public var id: CanvasToolKind { kind }

  /// This was previously a stored property on the tool, however tools seem to only
  /// need Tap and Drag operations, so have hard coded this for now.
  var inputCapabilities: InteractionKinds { .tapAndDrag }
}

extension CanvasTool where Self == SelectTool {
  public static var `default`: any CanvasTool { SelectTool() }
}

extension Array where Element == (any CanvasTool) {
  public static var defaultTools: Self {
    [SelectTool(), PanTool(), ZoomTool()]
  }
}
