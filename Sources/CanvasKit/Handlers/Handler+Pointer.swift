//
//  Handler+Pointer.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/1/2026.
//

import CoreTools
import Foundation
import GestureKit

public struct PointerHoverHandler {
  public var context: ViewportContext

  public init(context: ViewportContext) {
    self.context = context
  }
}

extension PointerHoverHandler {
  public var canvasRect: CGRect {
    CGRect(origin: .zero, size: context.canvasSize.cgSize)
  }

  public func isInsideCanvas(_ canvasPoint: CGPoint) -> Bool {
    canvasPoint.x >= 0
      && canvasPoint.x < context.canvasSize.width
      && canvasPoint.y >= 0
      && canvasPoint.y < context.canvasSize.height
  }

  public func map(screenPoint: CGPoint) -> HoverMapping {
    let canvas = context.toCanvas(
      screenPoint: Point<ScreenSpace>(fromPoint: screenPoint)
    )
    let canvasPoint = CGPoint(x: canvas.x, y: canvas.y)
    let isInside = isInsideCanvas(canvasPoint)

    return HoverMapping(
      screen: screenPoint,
      canvas: canvasPoint,
      isInsideCanvas: isInside
    )
  }

  public func mapIfInside(
    screenPoint: CGPoint
  ) -> HoverMapping? {
    let mapped = map(screenPoint: screenPoint)
    return mapped.isInsideCanvas ? mapped : nil
  }

  #if DEBUG
  public func roundTripError(screenPoint: CGPoint) -> CGFloat {
    let mapped = map(screenPoint: screenPoint)
    let roundTrip = context.toGlobal(point: mapped.canvas)
    return hypot(
      roundTrip.x - screenPoint.x,
      roundTrip.y - screenPoint.y
    )
  }
  #endif
}

/// These are not neccesarily defined by the number of fingers
///
/// PointerInteraction
/// - operates in content space
/// - usually single primary pointer
/// - absolute positions matter
///
/// GestureInteraction
/// - operates in view / world / mode space
/// - often multi-pointer
/// - relative motion matters
///

//struct PointerHandler {
//  let phase: PointerPhase? = nil
//}
//
//extension PointerHandler {
//  mutating func update(
//    for kind: PointerInteractionKind,
//    phase: PointerPhase?
//  ) {
//
//  }
//}
//
//public enum PointerInteractionKind {
//  case tap
//  case drag
//  case hover
//}
