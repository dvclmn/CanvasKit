//
//  CanvasPointerHoverMapper.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import CoreTools

public struct CanvasPointerHoverMapping: Equatable {
  public let screen: CGPoint
  public let canvas: CGPoint
  public let isInsideCanvas: Bool

  public init(
    screen: CGPoint,
    canvas: CGPoint,
    isInsideCanvas: Bool
  ) {
    self.screen = screen
    self.canvas = canvas
    self.isInsideCanvas = isInsideCanvas
  }
}

public struct CanvasPointerHoverMapper {
  public var context: ViewportContext

  public init(context: ViewportContext) {
    self.context = context
  }
}

extension CanvasPointerHoverMapper {
  public var canvasRect: CGRect {
    CGRect(origin: .zero, size: context.canvasSize.cgSize)
  }

  public func isInsideCanvas(_ canvasPoint: CGPoint) -> Bool {
    canvasPoint.x >= 0
      && canvasPoint.x < context.canvasSize.width
      && canvasPoint.y >= 0
      && canvasPoint.y < context.canvasSize.height
  }

  public func map(screenPoint: CGPoint) -> CanvasPointerHoverMapping {
    let canvas = context.toCanvas(
      screenPoint: Point<ScreenSpace>(fromPoint: screenPoint)
    )
    let canvasPoint = CGPoint(x: canvas.x, y: canvas.y)
    let isInside = isInsideCanvas(canvasPoint)

    return CanvasPointerHoverMapping(
      screen: screenPoint,
      canvas: canvasPoint,
      isInsideCanvas: isInside
    )
  }

  public func mapIfInside(
    screenPoint: CGPoint
  ) -> CanvasPointerHoverMapping? {
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
