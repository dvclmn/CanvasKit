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
  let resolver: ZoomFocusResolver
}
