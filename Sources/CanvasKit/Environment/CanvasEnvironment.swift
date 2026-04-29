//
//  CanvasEnvironment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//

import GeometryPrimitives
import InputPrimitives
import CoreUtilities
import SwiftUI

/// If and when a user needs *direct* access to any of these,
/// I can change internal/package to public
extension EnvironmentValues {

  /// Aka artwork/document size. Used internally by CanvasKit only
  @Entry var canvasSize: Size<CanvasSpace>?
  
  @Entry var isShowingToolPicker: Bool = false
  @Entry var toolPickerAlignment: Alignment = .topLeading

  /// `canvasAnchor` is useful for both Canvas and Grid domains.
  /// Describes the anchor point for layout in ``CanvasArtworkView``.
  /// Important for coordinate space calculations.
  ///
  /// Though I don't think there's any usefulness in having
  /// it configurable?
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

  @Entry public var panOffset: CGSize = .zero
  @Entry public var rotation: Angle = .zero

  /// Important: This zoom level is not clamped. Use ``zoomClamped``
  /// (which clamps by ``zoomRange``) if clamping is required
  @Entry public var zoomLevel: Double = 1.0

  @Entry public var zoomRange: ClosedRange<Double> = 0.2...10

  /// Returns `1.0` if `zoomLevel` is less than zero or NaN/infinite
  public var zoomClamped: Double {
    guard zoomLevel.isFiniteAndGreaterThanZero else { return 1.0 }
    return zoomLevel.clamped(to: zoomRange)
  }
  
  
}
