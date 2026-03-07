//
//  Native+PointerHover.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 6/3/2026.
//

import BasePrimitives
import Foundation

//public struct PointerHoverMapper {
//  public var artworkFrameInViewport: CGRect
//  public var canvasSize: Size<CanvasSpace>
//  public var zoom: CGFloat
//
//  public init(
//    artworkFrameInViewport: CGRect,
//    canvasSize: Size<CanvasSpace>,
//    zoom: CGFloat
//  ) {
//    self.artworkFrameInViewport = artworkFrameInViewport
//    self.canvasSize = canvasSize
//    self.zoom = zoom
//  }
//}
//
//extension PointerHoverMapper {
//
//
//}
//
//// MARK: - Containment check
//
//extension PointerHoverMapper {
//
//
//}

// MARK: - Debug
//extension PointerHoverMapper {
//  #if DEBUG
//  public func roundTripError(viewportPoint: CGPoint) -> CGFloat {
//    let mapped = map(viewportPoint: viewportPoint)
//    let roundTrip = CGPoint(
//      x: (mapped.canvas.x * zoomSafe) + artworkFrameInViewport.minX,
//      y: (mapped.canvas.y * zoomSafe) + artworkFrameInViewport.minY
//    )
//    return hypot(
//      roundTrip.x - viewportPoint.x,
//      roundTrip.y - viewportPoint.y
//    )
//  }
//  #endif
//}
