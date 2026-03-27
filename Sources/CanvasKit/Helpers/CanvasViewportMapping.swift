//
//  CanvasViewportMapping.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import SwiftUI

//public struct CanvasViewportMapping {
//
//  /// In global/screen space; includes safe-area origin and size.
//  public var viewportRect: Rect<ScreenSpace>
//  public var pan: Size<ScreenSpace>
//  public var zoom: CGFloat
//  public var canvasSize: Size<CanvasSpace>
//  public var anchor: UnitPoint
//
//  public init(
//    viewportRect: Rect<ScreenSpace>,
//    pan: Size<ScreenSpace>,
//    zoom: CGFloat,
//    canvasSize: Size<CanvasSpace>,
//    anchor: UnitPoint
//  ) {
//    self.viewportRect = viewportRect
//    self.pan = pan
//    self.zoom = zoom
//    self.canvasSize = canvasSize
//    self.anchor = anchor
//  }
//}
//
//extension CanvasViewportMapping {
//
//  private var zoomSafe: CGFloat {
//    assert(zoom.isFinite, "CanvasViewportMapping: zoom became non-finite")
//    /// I may consider a different value for max, like 20 or 80 or whatever makes sense
//    return zoom.clamped(to: 0.06...CGFloat.greatestFiniteMagnitude)
//  }
//
//  /// Computes the centering offset for a given anchor,
//  /// given the viewport size and the scaled canvas size.
//  /// - Parameters:
//  ///   - anchor: The anchor point (0..1 in each axis) describing
//  ///     how the canvas should be positioned within the viewport.
//  ///   - viewportSize: The viewport size in screen space (safe-area insets already applied).
//  ///   - scaledCanvasSize: The canvas size after applying zoom.
//  /// - Returns: The offset in screen space to position the scaled
//  ///   canvas within the viewport for the provided anchor.
//  static func centeringOffset(
//    for anchor: UnitPoint,
//    viewportSize: CGSize,
//    scaledCanvasSize: CGSize
//  ) -> CGSize {
//    /// Clamp to [0, 1] to be safe for custom UnitPoints
//    let ax = max(0, min(1, anchor.x))
//    let ay = max(0, min(1, anchor.y))
//
//    /// Compute how much extra space remains after scaling, then place according to anchor
//    let offsetX = (viewportSize.width - scaledCanvasSize.width) * ax
//    let offsetY = (viewportSize.height - scaledCanvasSize.height) * ay
//
//    return CGSize(width: offsetX, height: offsetY)
//  }
//
//  /// The dynamic offset to center the canvas within the safe viewport area.
//  /// This uses the size of the viewport (which already has insets subtracted).
//  /// Canvas is scaled by zoom for centering; viewportRect is never scaled.
//  private var centeringOffset: CGSize {
//
//    /// Size of the canvas once zoom is applied
//    let scaledCanvasSize = CGSize(
//      width: canvasSize.width * zoomSafe,
//      height: canvasSize.height * zoomSafe
//    )
//
//    let viewportSize = CGSize(width: viewportRect.width, height: viewportRect.height)
//
//    return Self.centeringOffset(
//      for: anchor,
//      viewportSize: viewportSize,
//      scaledCanvasSize: scaledCanvasSize
//    )
//  }
//
//  /// Canvas frame expressed in global/screen space.
//  public var canvasFrameInGlobalSpace: CGRect {
//    CGRect(
//      origin: totalGlobalOffset,
//      size: CGSize(
//        width: canvasSize.width * zoomSafe,
//        height: canvasSize.height * zoomSafe
//      )
//    )
//  }
//
//  /// The "Zero Point" of your drawing area in screen space.
//  /// Safe Area Origin + Centering + Manual Pan.
//  private var totalGlobalOffset: CGPoint {
//    CGPoint(
//      x: viewportRect.origin.x + centeringOffset.width + pan.width,
//      y: viewportRect.origin.y + centeringOffset.height + pan.height
//    )
//  }
//
//  /// Converts a global/screen space point to local / canvas point
//  /// Previously: `toLocal(point:) - > CGPoint`
//  public func toCanvas(screenPoint point: CGPoint) -> Point<CanvasSpace> {
////  public func toCanvas(screenPoint point: Point<ScreenSpace>) -> Point<CanvasSpace> {
//    /// 1. Subtract the total translation from the raw screen point
//    /// 2. Divide by zoom to get the coordinate on the "original" canvas scale
//    Point<CanvasSpace>(
//      x: (point.x - totalGlobalOffset.x) / zoomSafe,
//      y: (point.y - totalGlobalOffset.y) / zoomSafe
//    )
//  }
//
//  /// Converts a canvas-local point back to screen/global space
//  public func toGlobal(point: CGPoint) -> CGPoint {
//    /// 1. Scale the local point up
//    /// 2. Add the total translation to place it correctly on the screen
//    CGPoint(
//      x: (point.x * zoomSafe) + totalGlobalOffset.x,
//      y: (point.y * zoomSafe) + totalGlobalOffset.y
//    )
//  }
//
//  /// Converts a global/screen rect to local/canvas rect.
//  public func toCanvas(rect: CGRect) -> CGRect {
//    let originCanvas = toCanvas(screenPoint: rect.origin)
////    let originCanvas = toCanvas(screenPoint: Point<ScreenSpace>(fromPoint: rect.origin))
//    return CGRect(
//      origin: originCanvas.cgPoint,
//      size: CGSize(
//        width: rect.width / zoomSafe,
//        height: rect.height / zoomSafe
//      )
//    )
//  }
//
//  /// Converts a local/canvas rect to global/screen rect.
//  public func toGlobal(rect: CGRect) -> CGRect {
//    CGRect(
//      origin: toGlobal(point: rect.origin),
//      size: CGSize(
//        width: rect.width * zoomSafe,
//        height: rect.height * zoomSafe
//      )
//    )
//  }
//}
