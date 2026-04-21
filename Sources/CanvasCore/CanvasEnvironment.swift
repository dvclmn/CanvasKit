//
//  CanvasEnvironment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//
import SwiftUI

extension EnvironmentValues {
  /// Important: This zoom level is not clamped. Use ``zoomClamped``
  /// which clamps by ``zoomRange`` if clamping is required
  
  @Entry public var zoomLevel: Double = 1.0
  
  /// This was previously optional, but trying out a default value instead
  @Entry public var zoomRange: ClosedRange<Double> = 0.2...10
  
  /// Will return unclamped if no zoom range found in the Environment
  public var zoomClamped: Double {
    guard zoomLevel.isFiniteAndGreaterThanZero else { return 1.0 }
    return zoomLevel.clamped(to: zoomRange)
  }
}
