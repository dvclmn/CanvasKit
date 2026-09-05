//
//  CoordSpaceMapper.swift
//  CanvasKit
//
//  Created by Dave Coleman on 17/3/2026.
//

import Foundation

/// Maps points using a uniform scale and the artwork's measured viewport origin.
///
/// ``CanvasView`` measures the local layout size and viewport frame together so that
/// pixel rounding of a requested document size is not mistaken for scaling.
/// Rotation and non-uniform transforms are not supported by this mapper.
public struct CoordinateSpaceMapper: Equatable {

  /// The canvas artwork as positioned in viewport coordinates.
  ///
  /// `origin`: Expresses the offset from the viewport origin (top-left)
  /// to the top left corner of the artwork.
  ///
  /// `size`: Expresses the measured layout size after zoom has been applied.
  public let artworkFrame: Rect<ViewportSpace>

  /// The logical document extent, which remains independent of layout rounding.
  public let canvasSize: Size<CanvasSpace>

  /// The unscaled layout extent corresponding to `artworkFrame`.
  let layoutSize: Size<CanvasSpace>

  /// Creates a mapper when `frame` is the uniformly scaled form of `canvasSize`.
  public init(
    frame: Rect<ViewportSpace>,
    canvasSize: Size<CanvasSpace>,
  ) {
    self.init(frame: frame, canvasSize: canvasSize, layoutSize: canvasSize)
  }

  init(
    frame: Rect<ViewportSpace>,
    canvasSize: Size<CanvasSpace>,
    layoutSize: Size<CanvasSpace>,
  ) {
    self.artworkFrame = frame
    self.canvasSize = canvasSize
    self.layoutSize = layoutSize
  }
}

extension CoordinateSpaceMapper {

  var zoom: CGFloat {
    switch (widthZoom, heightZoom) {
      case (.some(let width), .some(let height)): min(width, height)
      case (.some(let width), .none): width
      case (.none, .some(let height)): height
      case (.none, .none): 1
    }
  }

  /// A dimensionless comparison, with the same meaning at every zoom level.
  var relativeScaleDifference: CGFloat? {
    guard let widthZoom, let heightZoom else { return nil }
    return abs(widthZoom - heightZoom) / max(widthZoom, heightZoom)
  }

  var hasNonUniformScale: Bool {
    relativeScaleDifference.map { $0 > 0.001 } ?? false
  }

  /// Read only when geometry enters a non-uniform state, never per pointer event.
  var nonUniformScaleDiagnostic: String? {
    guard hasNonUniformScale,
      let widthZoom, let heightZoom, let relativeScaleDifference
    else { return nil }

    return """
      CanvasKit warning: measured artwork geometry implies non-uniform scaling.
      Inferred x: \(widthZoom), y: \(heightZoom); relative difference: \(relativeScaleDifference * 100)% (tolerance: 0.1%).
      Viewport frame: \(artworkFrame.cgRect); unscaled layout size: \(layoutSize.cgSize); logical canvas size: \(canvasSize.cgSize).
      The mapper uses the smaller scale, \(zoom), for both axes. Check for rotation or non-uniform transforms; mapped input may be inaccurate. This warning is reported once until uniform geometry resumes.
      """
  }

  private var widthZoom: CGFloat? {
    inferredZoom(viewportExtent: artworkFrame.width, layoutExtent: layoutSize.width)
  }

  private var heightZoom: CGFloat? {
    inferredZoom(viewportExtent: artworkFrame.height, layoutExtent: layoutSize.height)
  }

  private func inferredZoom(viewportExtent: CGFloat, layoutExtent: CGFloat) -> CGFloat? {
    guard viewportExtent.isFinite, viewportExtent > 0,
      layoutExtent.isFinite, layoutExtent > 0
    else { return nil }
    let scale = viewportExtent / layoutExtent
    return scale.isFinite && scale > 0 ? scale : nil
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
