//
//  CoordSpaceMapper.swift
//  CanvasKit
//
//  Created by Dave Coleman on 17/3/2026.
//

import Foundation

public struct CoordinateSpaceMapper: Equatable {

  /// The canvas artwork as it's situated in the Viewport,
  /// captured via Anchor preference key in `CanvasCoreView`.
  ///
  /// `origin`:  Expresses the offset from the Viewport origin (top left),
  /// to the top left corner of the artwork.
  ///
  /// `size`: Expresses the canvas size scaled by zoom
  public let artworkFrame: Rect<ViewportSpace>
  public let canvasSize: Size<CanvasSpace>

  public init(
    frame: Rect<ViewportSpace>,
    canvasSize: Size<CanvasSpace>,
  ) {
    self.artworkFrame = frame
    self.canvasSize = canvasSize
  }
}

extension CoordinateSpaceMapper {

  @inlinable
  var zoom: CGFloat {
    let widthZoom: CGFloat
    let heightZoom: CGFloat

    if canvasSize.width != 0 {
      widthZoom = artworkFrame.width / canvasSize.width
    } else {
      widthZoom = 1.0
    }

    if canvasSize.height != 0 {
      heightZoom = artworkFrame.height / canvasSize.height
    } else {
      heightZoom = 1.0
    }

    /// Check for NaN, Inf, or negative scales as well
    let validWidth = widthZoom.isFinite && widthZoom > 0
    let validHeight = heightZoom.isFinite && heightZoom > 0

    /// Use minimum valid zoom, fallback to 1.0 if both are invalid
    if validWidth && validHeight {
      /// If they differ significantly:
      if abs(widthZoom - heightZoom) > 0.001 {
        print("Warning: Zoom level is showing non-uniform scaling.")
      }
      return min(widthZoom, heightZoom)

    } else if validWidth {
      return widthZoom

    } else if validHeight {
      return heightZoom

    } else {
      return 1.0
    }
  }

  /// ```
  /// // canvas → screen: scale first, then translate
  /// // viewportPoint = zoom * canvasPoint + artworkFrame.origin
  /// let canvasToViewport = CGAffineTransform(
  ///   translationX: artworkFrame.minX,
  ///   y: artworkFrame.minY
  /// ).scaledBy(x: zoom, y: zoom)
  /// //  ^ .scaledBy() prepends the scale, so the effective order is:
  /// //    scale the point, *then* apply the translation — which is what we want
  /// ```

  /// Transforms a canvas-space point to a screen-space point.
  /// Encodes: screenPoint = zoom × canvasPoint + artworkFrame.origin
  public var canvasToViewport: CGAffineTransform {
    CGAffineTransform(translationX: artworkFrame.minX, y: artworkFrame.minY)
      .scaledBy(x: zoom, y: zoom)
  }

  /// The inverse: transforms a screen-space point to a canvas-space point.
  /// Encodes: canvasPoint = (screenPoint - artworkFrame.origin) / zoom
  public var viewportToCanvas: CGAffineTransform {
    canvasToViewport.inverted()
  }

  /// Convert screen-space point to canvas-space
  public func canvasPoint(from screenPoint: Point<ViewportSpace>) -> Point<CanvasSpace> {
    Point<CanvasSpace>(
      x: (screenPoint.x - artworkFrame.minX) / zoom,
      y: (screenPoint.y - artworkFrame.minY) / zoom,
    )
  }

  /// Convert canvas-space point to screen-space
  func screenPoint(from canvasPoint: Point<CanvasSpace>) -> Point<ViewportSpace> {
    Point<ViewportSpace>(
      x: artworkFrame.minX + canvasPoint.x * zoom,
      y: artworkFrame.minY + canvasPoint.y * zoom,
    )
  }

  /// Convert screen-space rect to canvas-space
  public func canvasRect(from viewportRect: Rect<ViewportSpace>) -> Rect<CanvasSpace> {
    let origin = canvasPoint(from: viewportRect.origin)
    return Rect<CanvasSpace>(
      x: origin.x,
      y: origin.y,
      width: viewportRect.width / zoom,
      height: viewportRect.height / zoom,
    )
  }

  public func isInsideCanvas(
    _ canvasPoint: Point<CanvasSpace>
  ) -> Bool {
    let xInBounds = (0..<canvasSize.width).contains(canvasPoint.x)
    let yInBounds = (0..<canvasSize.height).contains(canvasPoint.y)
    return xInBounds && yInBounds
  }
}
