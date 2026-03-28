//
//  CanvasCoordinateSpace.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 25/2/2026.
//

import InteractionPrimitives
import SwiftUI

extension EnvironmentValues {

  // MARK: - Geometry
  /// This is usable by both Canvas and Grid domains. Describes the anchor
  /// used for SwiftUI layout by the main Artwork View in a CanvasView.
  /// Important for coordinate space calculations.
  @Entry public var canvasAnchor: UnitPoint = .center

  /// Aka artwork size, document size
  @Entry public var canvasSize: Size<CanvasSpace>?
  @Entry public var artworkFrameInViewport: Rect<ScreenSpace>?
  @Entry public var canvasBackground: Color = Color(white: 0.04)

  @Entry public var canvasInputPolicy: CanvasInputPolicy = .standard
  @Entry public var activeTool: (any CanvasTool)?

  public var canvasGeometry: CanvasGeometry? {
    guard let viewportRect,
      let artworkFrameInViewport,
      let canvasSize
    else {
      //      print(
      //        "For canvasGeometry, missing one of:\nviewportRect: \(String(describing: viewportRect)), artworkFrameInViewport: \(String(describing: artworkFrameInViewport)), or canvasSize: \(String(describing: canvasSize))\n\n"
      //      )
      return nil
    }
    return CanvasGeometry(
      viewportRect: Rect<ScreenSpace>(fromRect: viewportRect),
      artworkFrameInViewport: artworkFrameInViewport,
      canvasSize: canvasSize,
      anchor: canvasAnchor,
    )
  }

  /// The hover location in resolved CanvasSpace (before pan/zoom)
  @Entry public var pointerLocation: CGPoint?
  @Entry public var pointerStyle: PointerStyleCompatible?

}
