//
//  CanvasEnvironment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//

import GeometryPrimitives
import InputPrimitives
import SwiftUI

/// If and when a user needs *direct* access to any of these,
/// I can change internal/package to public
extension EnvironmentValues {

  /// Aka artwork/document size. Used internally by CanvasKit only
  @Entry var canvasSize: Size<CanvasSpace>?

  /// `canvasAnchor` is useful for both Canvas and Grid domains.
  /// Describes the anchor point for layout in ``CanvasArtworkView``.
  /// Important for coordinate space calculations.
  @Entry var canvasAnchor: UnitPoint = .center
  @Entry var canvasBackground: Color = Color(white: 0.04)

  // TODO: Comments like the below are better suited to
  // a page in the Doc catalogue, not inline doc comment.
  
  /// Pointer Tap, Drag and Hover are added to the environment as
  /// an internal convenience. For user access, see Canvas event
  /// modifiers like `CanvasDragModifier`.
  @Entry package var pointerTap: Point<CanvasSpace>?
  @Entry package var pointerDrag: Rect<CanvasSpace>?
  @Entry package var pointerHover: Point<CanvasSpace>?

  // TODO: If BasePrimitives/InputPrimitives owns InteractionPhase,
  // maybe it should be added as Env value there, not here
  @Entry package var interactionPhase: InteractionPhase = .none
}
