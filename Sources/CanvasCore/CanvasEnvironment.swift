//
//  CanvasEnvironment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//
import SwiftUI

/// If and when a user needs *direct* access to any of these,
/// I can change package to public
extension EnvironmentValues {

  /// Package BaseHelpers needs the below pan/rotation/zoom etc
  /// for `GridLineContext`. Going to suss whether to expose
  /// to BaseHelpers only via `@_spi(Internals)`, or whether
  /// it's fine that CanvasKit users will see these, as is.
  @Entry public var panOffset: CGSize = .zero
  @Entry public var rotation: Angle = .zero

  /// Important: This zoom level is not clamped. Use ``zoomClamped``
  /// which clamps by ``zoomRange`` if clamping is required

  @Entry public var zoomLevel: Double = 1.0

  /// This was previously optional, but trying out a default value instead
  @Entry public var zoomRange: ClosedRange<Double> = 0.2...10

  /// Will return unclamped if no zoom range found in the Environment
  package var zoomClamped: Double {
    guard zoomLevel.isFiniteAndGreaterThanZero else { return 1.0 }
    return zoomLevel.clamped(to: zoomRange)
  }

  /// Aka artwork/document size. Used internally by CanvasKit only
  @Entry package var canvasSize: Size<CanvasSpace>?

  /// Captured by SwiftUI Anchor preference key. The rect origin expresses
  /// the `panOffset` (from the top left), and the rect size expresses
  /// the `canvasSize` scaled by the current `zoomLevel`
  @Entry package var artworkFrameInViewport: Rect<ScreenSpace>?

  /// Note: See swift package `BasePrimitives` for zoom, pan and rotate

  /// Pointer hover location in `CanvasSpace` (i.e. before pan/zoom)
  @Entry package var pointerHover: Point<CanvasSpace>?
  @Entry package var pointerTap: Point<CanvasSpace>?
  @Entry package var pointerDrag: Rect<CanvasSpace>?
}
