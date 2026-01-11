//
//  CanvasMappedValue.swift
//  BaseComponents
//
//  Created by Dave Coleman on 28/7/2025.
//

import BasePrimitives
import GestureKit
import SwiftUI

/// Unless I otherwise specify an alignment below, this helper
/// assumes the Canvas has a default `center` alignment
/// within the viewport, before any pan or zoom etc.
public struct CanvasTransformContext: Equatable, Sendable {
  public let viewportSize: CGSize
  public let canvasSize: CGSize
  public let zoom: CGFloat
  public let pan: CGSize
  public let rotation: Angle

  public init(
    viewportSize: CGSize,
    canvasSize: CGSize,
    zoom: CGFloat,
    pan: CGSize,
    rotation: Angle
  ) {
    self.viewportSize = viewportSize
    self.canvasSize = canvasSize
    self.zoom = zoom
    self.pan = pan
    self.rotation = rotation
  }
}

extension CanvasTransformContext {

  public static var zero: Self {
    .init(
      viewportSize: .zero,
      canvasSize: .zero,
      zoom: 1,
      pan: .zero,
      rotation: .zero
    )
  }

  public init?(
    viewportSize: CGSize?,
    canvasSize: CGSize?,
    zoom: CGFloat,
    pan: CGSize,
    rotation: Angle,
  ) {
    guard let viewportSize, let canvasSize else {
      //      print("No value for canvasSize, unable to create CanvasTransformContext")
      return nil
    }
    self.viewportSize = viewportSize
    self.canvasSize = canvasSize
    self.zoom = zoom
    self.pan = pan
    self.rotation = rotation
  }

  public func dragRect(for rect: CGRect) -> CGRect? {
    mapToCanvas(viewportRect: rect)
  }
  public func dragRect(for phase: PointerPhase) -> CGRect? {
    guard let rect = phase.dragValue else { return nil }
    return dragRect(for: rect)
  }

  public func tapLocation(for location: CGPoint) -> CGPoint? {
    mapToCanvas(viewportPoint: location)
  }

  private var dimensionsAreValid: Bool {
    viewportSize.isGreaterThanZero && canvasSize.isGreaterThanZero
  }

  private var canvasOriginInViewport: CGPoint {
    let centredOffset = viewportSize.centeringOffset(forChild: zoomedCanvasSize)
    let pannedOffset: CGSize = centredOffset + pan
    return pannedOffset.toCGPoint
  }

  private var zoomedCanvasSize: CGSize { canvasSize * zoom }

  public var canvasFrameInViewport: CGRect {
    precondition(dimensionsAreValid, "Viewport and Canvas sizes cannot be zero along either dimension.")
    let origin = canvasOriginInViewport
    let size = zoomedCanvasSize
    return CGRect(origin: origin, size: size)
  }

  /// Map Point to Canvas space
  public func mapToCanvas(
    viewportPoint point: CGPoint
  ) -> CGPoint? {
    let translated: CGPoint = point - canvasFrameInViewport.origin
    let result: CGPoint = translated.removingZoom(zoom)
    return result
  }

  /// Map Rect to Canvas space.
  public func mapToCanvas(
    viewportRect rect: CGRect
  ) -> CGRect? {
    guard let origin = mapToCanvas(viewportPoint: rect.origin) else { return nil }
    let size = rect.size.removingZoom(zoom)
    return CGRect(origin: origin, size: size)
  }

}

extension CanvasTransformContext: CustomStringConvertible {
  public var description: String {
    return """

      Viewport size: \(viewportSize.displayString)
      Canvas size: \(canvasSize.displayString)

      Zoom: \(zoom.displayString)
      Pan: \(pan.displayString)
      Rotation: \(rotation.degrees.displayString)

      """
  }
}
