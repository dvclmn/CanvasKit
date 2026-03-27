//
//  ZoomGestureEvent.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 1/3/2026.
//

import Foundation

public struct ZoomGestureEvent: Sendable {

  /// Zoom level before applying the latest magnification delta.
  public var previousZoom: Double

  /// Proposed zoom after applying the latest delta (before any override).
  public var proposedZoom: Double

  /// Absolute magnification since gesture start (`1` means unchanged).
  public var magnification: Double

  /// Incremental magnification since the previous update (`1` means unchanged).
  public var magnificationDelta: Double

  /// True for the first update event in a gesture.
  public var isGestureStart: Bool

  public init(
    previousZoom: Double,
    proposedZoom: Double,
    magnification: Double,
    magnificationDelta: Double,
    isGestureStart: Bool
  ) {
    self.previousZoom = previousZoom
    self.proposedZoom = proposedZoom
    self.magnification = magnification
    self.magnificationDelta = magnificationDelta
    self.isGestureStart = isGestureStart
  }
}
