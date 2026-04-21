//
//  Interaction+Env.swift
//  InteractionKit
//
//  Created by Dave Coleman on 28/3/2026.
//

import SwiftUI
import CanvasCore

extension EnvironmentValues {

  /// Aka artwork/document size. Used internally by CanvasKit only
  @Entry package var canvasSize: Size<CanvasSpace>?

  /// Captured by SwiftUI Anchor preference key. The rect origin expresses
  /// the `panOffset` (from the top left), and the rect size expresses
  /// the `canvasSize` scaled by the current `zoomLevel`
  @Entry public var artworkFrameInViewport: Rect<ScreenSpace>?

  /// Note: See swift package `BasePrimitives` for zoom, pan and rotate

  /// Pointer hover location in `CanvasSpace` (i.e. before pan/zoom)
  @Entry public var pointerHover: Point<CanvasSpace>?
  @Entry public var pointerTap: Point<CanvasSpace>?
  @Entry public var pointerDrag: Rect<CanvasSpace>?

  @Entry public var interactionPhase: InteractionPhase = .none
}
