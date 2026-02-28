//
//  Handler+PointerHoverMapping.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import CoreTools
import SwiftUI

extension CanvasHandler {
  public var viewportContext: ViewportContext? {
    guard geometry.isValidForCoordinateMapping else { return nil }
    return geometry.viewportContext(
      zoom: CGFloat(zoomClamped),
      pan: pan
    )
  }

  public var pointerHoverMapper: PointerHoverHandler? {
    guard let viewportContext else { return nil }
    return PointerHoverHandler(context: viewportContext)
  }

  public var pointerHoverGlobal: CGPoint? {
    pointerHover.value
  }

  public var pointerHoverMapped: HoverMapping? {
    guard let pointerHoverGlobal, let mapper = pointerHoverMapper else { return nil }
    return mapper.map(screenPoint: pointerHoverGlobal)
  }

  /// Aka canvas local space
  public var pointerHoverCanvas: CGPoint? {
    pointerHoverMapped?.canvas
  }

  /// Nil when the hover point is outside the canvas bounds.
  public var pointerHoverCanvasIfInside: CGPoint? {
    guard let mapped = pointerHoverMapped, mapped.isInsideCanvas else { return nil }
    return mapped.canvas
  }

  public var isPointerHoverInsideCanvas: Bool {
    pointerHoverMapped?.isInsideCanvas ?? false
  }

  public func updateHover(_ phase: HoverPhase) {
    pointerHover.update(phase)
  }

  #if DEBUG
  public var pointerHoverRoundTripError: CGFloat? {
    guard let pointerHoverGlobal, let mapper = pointerHoverMapper else { return nil }
    return mapper.roundTripError(screenPoint: pointerHoverGlobal)
  }
  #endif
}
