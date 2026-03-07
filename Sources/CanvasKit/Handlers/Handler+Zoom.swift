//
//  Handler+Zoom.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 7/3/2026.
//

import BasePrimitives
import Foundation

struct ZoomHandler {
  let zoomEvent: ZoomGestureEvent
  let geometry: CanvasGeometry
}

extension ZoomHandler {
  private var viewportCentre: CGPoint { geometry.viewportRect.midpoint }
//    CGPoint(
//      x: geometry.viewportRect.midX,
//      y: geometry.viewportRect.midY
//    )
//  }
}
