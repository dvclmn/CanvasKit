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
