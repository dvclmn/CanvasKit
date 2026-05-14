//
//  CanvasEnvironment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//


import InputPrimitives
import CoreUtilities
import SwiftUI

/// If and when a user needs *direct* access to any of these,
/// I can change internal/package to public
extension EnvironmentValues {

  /// A concrete canvas size, if passed by the caller. If value is nil, canvas size
  /// will be inferred via `CanvasHandler/resolvedCanvasSize(for:)`.
  @Entry var explicitCanvasSize: Size<CanvasSpace>?
  
  @Entry public var canvasClipping: Binding<CanvasClipping> = .constant(.clipped)

  /// Resolved mapper between the visible viewport and artwork coordinates.
  ///
  /// This is available within the ``CanvasView`` hierarchy once the artwork
  /// frame has been resolved from SwiftUI layout. The mapper uses the captured
  /// artwork frame rather than recomputing from pan/zoom values.
  @Entry public var canvasCoordinateSpaceMapper: CoordinateSpaceMapper?
  
  /// Current runtime transform state
//  @Entry var transform: TransformState?
  
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

  @Entry var activeInteraction: ActiveInteraction = .none
  

  @Entry public var panOffset: CGSize = .zero
  @Entry public var rotation: Angle = .zero

  /// Important: This zoom level is not clamped. Use ``zoomClamped``
  /// (which clamps by ``zoomRange``) if clamping is required
  @Entry public var zoomLevel: Double = 1.0

  @Entry public var zoomRange: ClosedRange<Double> = 0.2...10
  @Entry public var zoomSensitivity: Double = 0.5

  /// Returns `1.0` if `zoomLevel` is less than zero or NaN/infinite
  public var zoomClamped: Double {
    guard zoomLevel.isFiniteAndGreaterThanZero else { return 1.0 }
    return zoomLevel.clamped(to: zoomRange)
  }
  
  
}
