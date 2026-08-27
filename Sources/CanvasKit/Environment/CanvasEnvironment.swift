//
//  CanvasEnvironment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//

private import CoreTools
import SwiftUI

extension EnvironmentValues {

  /// A concrete canvas size, if passed by the caller. If value is nil, canvas size
  /// will be inferred via `CanvasHandler/resolvedCanvasSize(for:)`.
  @Entry var explicitCanvasSize: Size<CanvasSpace>?

//  @Entry public var canvasClipping: Binding<CanvasClipping> = .constant(.clipped)

  /// Resolved mapper between the visible viewport and artwork coordinates.
  ///
  /// This is available within the ``CanvasView`` hierarchy once the artwork
  /// frame has been resolved from SwiftUI layout. The mapper uses the captured
  /// artwork frame rather than recomputing from pan/zoom values.
//  @Entry public var canvasCoordinateSpaceMapper: CoordinateSpaceMapper?

  @Entry var isShowingToolPalette: Bool = false
//  @Entry var toolPaletteAlignment: Alignment = .topLeading

  /// Anchor point used to lay out artwork within the viewport.
  @Entry var canvasAnchor: UnitPoint = .center
//  @Entry var canvasBackground: Color = Color(white: 0.04)

  /// Mapped pointer observations used internally by Canvas event modifiers.
  @Entry var pointerTap: PointerTapSnapshot<CanvasSpace>?
  @Entry var pointerHover: Point<CanvasSpace>?
  @Entry var canvasDragEvent: CanvasDragEvent?

  @Entry public var panOffset: CGSize = .zero
  @Entry public var rotation: Angle = .zero

  /// Important: This zoom level is not clamped. Use ``zoomClamped``
  /// (which clamps by ``zoomRange``) if clamping is required
  @Entry public var zoomLevel: Double = 1.0

  @Entry public var zoomRange: ClosedRange<Double> = 0.2...10
  @Entry public var zoomSensitivity: Double = 0.5

  /// Returns `1.0` if `zoomLevel` is less than zero or NaN/infinite
  public var zoomClamped: Double {
    guard zoomLevel.isFiniteAndPositive else { return 1.0 }
    return zoomLevel.clamped(to: zoomRange)
  }

}
