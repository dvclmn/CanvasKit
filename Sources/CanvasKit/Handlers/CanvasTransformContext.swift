//
//  CanvasMappedValue.swift
//  BaseComponents
//
//  Created by Dave Coleman on 28/7/2025.
//

import CoreTools
import GestureKit
import SwiftUI

/// This is probably useful, just on hold for now
struct CanvasState {
//  var transform: CanvasTransform
  
  var activeMarquee: CGRect?
//  var selection: Set<ItemID>
}


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
//  public func dragRect(for phase: InteractionKind) -> CGRect? {
//    guard let rect = phase.dragValue else { return nil }
//    return dragRect(for: rect)
//  }

  public func tapLocation(for location: CGPoint) -> CGPoint? {
    mapToCanvas(viewportPoint: location)
  }

  private var dimensionsAreValid: Bool {
    viewportSize.isGreaterThanZero && canvasSize.isGreaterThanZero
  }

  private var viewportRect: CGRect {
    .init(origin: .zero, size: viewportSize)
  }

  /// Canonical transform used by all viewport <-> canvas mapping.
  private var coordinateTransform: CoordinateSpaceContext {
    .init(
      viewAnchor: .anchoredToCentre,
      zoom: zoom,
      pan: pan,
      viewportRect: viewportRect,
      canvasSize: canvasSize,
      panSpace: .global
    )
  }

  public var canvasFrameInViewport: CGRect {
    precondition(
      dimensionsAreValid,
      "Viewport and Canvas sizes cannot be zero along either dimension."
    )
    return coordinateTransform.canvasFrameInGlobalSpace
  }

  /// Map Point to Canvas space
  public func mapToCanvas(
    viewportPoint point: CGPoint
  ) -> CGPoint? {
    guard dimensionsAreValid else { return nil }

    #if DEBUG
    coordinateTransform.assertRoundTrip(global: point)
    #endif

    return coordinateTransform.toLocal(point: point)
  }

  /// Map Rect to Canvas space.
  public func mapToCanvas(
    viewportRect rect: CGRect
  ) -> CGRect? {
    guard dimensionsAreValid else { return nil }
    return coordinateTransform.toLocal(rect: rect)
  }

  #if DEBUG
  public func roundTripError(viewportPoint point: CGPoint) -> CGFloat? {
    guard dimensionsAreValid else { return nil }
    return coordinateTransform.roundTripError(global: point)
  }
  #endif

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
