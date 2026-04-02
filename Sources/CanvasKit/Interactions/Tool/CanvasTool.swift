//
//  CanvasTool.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import InteractionPrimitives
import SwiftUI

/// A canvas tool defines how pointer interactions (tap, drag) are interpreted.
///
/// Global gestures (swipe→pan, pinch→zoom, hover) are handled centrally
/// by `CanvasInteractionState` and never reach `resolvePointerInteraction()`.
/// Tools only receive pointer events: taps and drags.
public protocol CanvasTool: Sendable, Identifiable where ID == CanvasToolKind {

  /// The tool's identity, used for keyboard binding lookups and registry.
  var kind: CanvasToolKind { get }

  /// Display name for toolbar UI.
  var name: String { get }

  /// SF Symbol name for toolbar UI.
  var icon: String { get }

  /// The input policy active when this tool is selected.
  /// Controls drag behaviour, pointer-drag-pan, etc.
  var dragBehaviour: DragBehavior { get }
  //  var inputPolicy: CanvasInputPolicy { get }

  /// Input sources this tool opts into for resolution.
  /// Defaults to `.pointerOnly`.
  var inputCapabilities: InteractionKinds { get }

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
  ) -> ToolResolution
}

extension CanvasTool {
  public var id: CanvasToolKind { kind }
  public var inputCapabilities: InteractionKinds { .pointerOnly }
}

extension CanvasTool where Self == SelectTool {
  public static var `default`: any CanvasTool { SelectTool() }
}

extension Array where Element == (any CanvasTool) {
  public static var defaultTools: Self {
    [SelectTool(), PanTool(), ZoomTool()]
  }
}
