//
//  CanvasGeometry.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/1/2026.
//

import CoreGraphics
import SwiftUI
import InteractionPrimitives

public struct CanvasGeometry: Sendable, Equatable {
  public var viewportRect: Rect<ScreenSpace>
  public var artworkFrameInViewport: Rect<ScreenSpace>
  public var anchor: UnitPoint
  public var canvasSize: Size<CanvasSpace>

  public static var zero: Self { .init() }

  public init(
    viewportRect: Rect<ScreenSpace> = .zero,
    artworkFrameInViewport: Rect<ScreenSpace> = .zero,
    canvasSize: Size<CanvasSpace> = .zero,
    anchor: UnitPoint = .center
  ) {
    self.viewportRect = viewportRect
    self.artworkFrameInViewport = artworkFrameInViewport
    self.canvasSize = canvasSize
    self.anchor = anchor
  }
}

extension CanvasGeometry {
  public var viewportSize: CGSize { viewportRect.cgRect.size }
}
