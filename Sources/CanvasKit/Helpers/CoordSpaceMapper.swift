//
//  CoordSpaceMapper.swift
//  CanvasKit
//
//  Created by Dave Coleman on 17/3/2026.
//

import Foundation

public struct CoordinateSpaceMapper: Equatable {

  /// The canvas artwork as positioned in viewport coordinates.
  ///
  /// `origin`: Expresses the offset from the viewport origin (top-left)
  /// to the top left corner of the artwork.
  ///
  /// `size`: Expresses the canvas size after zoom has been applied.
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

    // Check for NaN, Inf, or negative scales as well.
    let validWidth = widthZoom.isFinite && widthZoom > 0
    let validHeight = heightZoom.isFinite && heightZoom > 0

    // The mapper supports uniform scale only. Use the smaller inferred scale
    // when both axes are valid, and fall back to 1.0 if neither is valid.
    if validWidth && validHeight {
      let resolvedZoom = min(widthZoom, heightZoom)
      let scaleDifference = abs(widthZoom - heightZoom)

      if scaleDifference > 0.001 {
        print("Warning: Zoom level is showing non-uniform scaling.")
//        print(
//          """
//          CanvasKit CoordinateSpaceMapper warning: inferred non-uniform viewport scale.
//          The mapper requires one uniform zoom, but the measured artwork frame implies x: \(widthZoom), y: \(heightZoom) (difference: \(scaleDifference)).
//          Artwork frame in ViewportSpace: origin: (\(artworkFrame.minX), \(artworkFrame.minY)), size: (\(artworkFrame.width), \(artworkFrame.height)); logical canvas size: (\(canvasSize.width), \(canvasSize.height)).
//          CanvasKit will use the smaller scale, \(resolvedZoom), for both axes, so mapped input remains isotropic but may be inaccurate on the other axis.
//          Check for non-uniform scale effects, transform effects, or rotation (whose axis-aligned frame changes both inferred scales). A one-off warning during a canvas-size or layout update can also be a transient frame/size mismatch. Grid-based callers should pass a logical canvas size derived from their untransformed unit size; integer coordinates do not themselves introduce non-uniform scaling.
//          """
//        )
      }
      return resolvedZoom

    } else if validWidth {
      return widthZoom

    } else if validHeight {
      return heightZoom

    } else {
      return 1.0
    }
  }

  /// ```
  /// // canvas -> viewport: scale first, then translate
  /// // viewportPoint = zoom * canvasPoint + artworkFrame.origin
  /// let canvasToViewport = CGAffineTransform(
  ///   translationX: artworkFrame.minX,
  ///   y: artworkFrame.minY
  /// ).scaledBy(x: zoom, y: zoom)
  /// //  ^ .scaledBy() prepends the scale, so the effective order is:
  /// //    scale the point, then apply the translation.
  /// ```

  /// Transforms a canvas-space point to a viewport-space point.
  /// Encodes: `viewportPoint = zoom * canvasPoint + artworkFrame.origin`.
  public var canvasToViewport: CGAffineTransform {
    CGAffineTransform(translationX: artworkFrame.minX, y: artworkFrame.minY)
      .scaledBy(x: zoom, y: zoom)
  }

  /// Transforms a viewport-space point to a canvas-space point.
  /// Encodes: `canvasPoint = (viewportPoint - artworkFrame.origin) / zoom`.
  public var viewportToCanvas: CGAffineTransform {
    canvasToViewport.inverted()
  }

  /// Converts a viewport-space point to canvas-space.
  public func canvasPoint(from screenPoint: Point<ViewportSpace>) -> Point<CanvasSpace> {
    Point<CanvasSpace>(
      x: (screenPoint.x - artworkFrame.minX) / zoom,
      y: (screenPoint.y - artworkFrame.minY) / zoom,
    )
  }

  /// Converts a canvas-space point to viewport-space.
  func screenPoint(from canvasPoint: Point<CanvasSpace>) -> Point<ViewportSpace> {
    Point<ViewportSpace>(
      x: artworkFrame.minX + canvasPoint.x * zoom,
      y: artworkFrame.minY + canvasPoint.y * zoom,
    )
  }

  /// Converts a viewport-space rect to canvas-space.
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
