//
//  Handler+CanvasGesture.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/6/2025.
//

import BasePrimitives
import SwiftUI

@Observable
public final class CanvasHandler {

  var zoomRange: ClosedRange<Double>?

  /// Zoom multiplier per click when using the Zoom tool tap.
  /// Default 0.25 means each click zooms by 25% (1.0 → 1.25 → 1.5625…).
  /// Consumers can adjust this to taste.
  public var zoomStepFactor: Double = 0.25

  /// Sensitivity for pointer-drag zoom (zoom delta per pixel of vertical drag).
  /// Positive values mean drag-up = zoom in.
  public var pointerZoomSensitivity: Double = 0.005

  public init() {}
}
