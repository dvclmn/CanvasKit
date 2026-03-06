//
//  CanvasPointerHoverMapper.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import CoreTools
import Foundation

public struct HoverMapping: Equatable {
  public let screen: CGPoint
  public let canvas: CGPoint
  public let isInsideCanvas: Bool

  public init(
    screen: Point<ScreenSpace>,
    canvas: Point<CanvasSpace>,
    isInsideCanvas: Bool
  ) {
    self.screen = screen.cgPoint
    self.canvas = canvas.cgPoint
    self.isInsideCanvas = isInsideCanvas
  }

  public init(
    screen: CGPoint,
    canvas: CGPoint,
    isInsideCanvas: Bool
  ) {
    self.screen = screen
    self.canvas = canvas
    self.isInsideCanvas = isInsideCanvas
  }

  public var screenPoint: Point<ScreenSpace> {
    .init(fromPoint: screen)
  }

  public var canvasPoint: Point<CanvasSpace> {
    .init(fromPoint: canvas)
  }
}
