//
//  CanvasEnvironment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//
import SwiftUI
import GeometryPrimitives

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
  
  /// Pointer hover location in `CanvasSpace` (i.e. before pan/zoom)
  /// package access to be accessible to CanvasKit.
  /// This depenancy shape probably needs revision
  @Entry package var pointerHover: Point<CanvasSpace>?
  @Entry package var pointerTap: Point<CanvasSpace>?
  @Entry package var pointerDrag: Rect<CanvasSpace>?
}
