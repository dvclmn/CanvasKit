//
//  CanvasCoordinateSpace.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 25/2/2026.
//

import SwiftUI
import

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
      anchor: canvasAnchor
    )
  }

  @Entry public var panOffset: CGSize = .zero
  @Entry public var rotation: Angle = .zero

  /// The hover location in resolved CanvasSpace (before pan/zoom)
  @Entry public var pointerLocation: CGPoint?
  @Entry public var pointerStyle: PointerStyleCompatible?

  // MARK: - Zoom
  @Entry public var zoomLevel: Double = 1.0
  @Entry public var zoomRange: ClosedRange<Double>?

  /// Will return unclamped if no zoom range found in the Environment
  public var zoomClamped: Double {
    guard zoomLevel.isFiniteAndGreaterThanZero else { return 1.0 }
    return zoomLevel.clampedIfNeeded(to: zoomRange)
  }

}
