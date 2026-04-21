//
//  CoordSpaceMapper.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import Foundation

public struct CoordinateSpaceMapper {

  /// The canvas artwork as it's situated in the Viewport,
  /// captured via Anchor preference key in `CanvasCoreView`.
  ///
  /// `origin`:  Expresses the offset from the Viewport origin (top left),
  /// to the top left corner of the artwork.
  ///
  /// `size`: Expresses the canvas size scaled by zoom
  public let artworkFrame: Rect<ScreenSpace>

  public let zoom: Double

  /// Zoom is expected to be provided already clamped to `zoomRange`.
  /// Clamped zoom value available from the Environment as `zoomClamped`
  public init(
    artworkFrame: Rect<ScreenSpace>,
    zoomClamped zoom: CGFloat,
  ) {
    self.artworkFrame = artworkFrame
    self.zoom = zoom
  }
}

extension CoordinateSpaceMapper {

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

  private var canvasSize: Size<CanvasSpace> {
    Size<CanvasSpace>(
      width: artworkFrame.width / zoom,
      height: artworkFrame.height / zoom,
    )
  }

  /// Convert screen-space point to canvas-space
  public func canvasPoint(from screenPoint: Point<ScreenSpace>) -> Point<CanvasSpace> {
    Point<CanvasSpace>(
      x: (screenPoint.x - artworkFrame.minX) / zoom,
      y: (screenPoint.y - artworkFrame.minY) / zoom,
    )
  }

  /// Convert canvas-space point to screen-space
  func screenPoint(from canvasPoint: Point<CanvasSpace>) -> Point<ScreenSpace> {
    Point<ScreenSpace>(
      x: artworkFrame.minX + canvasPoint.x * zoom,
      y: artworkFrame.minY + canvasPoint.y * zoom,
    )
  }

  /// Convert screen-space rect to canvas-space
  public func canvasRect(from screenRect: Rect<ScreenSpace>) -> Rect<CanvasSpace> {
    let origin = canvasPoint(from: screenRect.origin)
    return Rect<CanvasSpace>(
      x: origin.x,
      y: origin.y,
      width: screenRect.width / zoom,
      height: screenRect.height / zoom,
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
