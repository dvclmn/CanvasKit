//
//  Canvas+Zoom.swift
//  BaseComponents
//
//  Created by Dave Coleman on 27/7/2025.
//

import Sharing
import SwiftUI

public struct ZoomHandler: Equatable, Sendable {
  public var zoom: CGFloat = 4.0
  public let zoomRange: ClosedRange<CGFloat> = 0.4...40.0
  @Shared(.canvasGeometry) private var geometry

  public init() {}
}

extension ZoomHandler {

  public var zoomPercent: CGFloat {
    let percent: CGFloat = zoom * 100
    let rounded = percent.rounded()
    return rounded
  }

  public var percentString: String {
    return "\(zoomPercent.displayString(places: 0))%"
  }

  public mutating func update(_ newValue: CGFloat) {
    zoom = newValue.clamped(to: zoomRange)
  }

  public mutating func reset() { zoom = 1.0 }

  public mutating func zoomToFit(padding: CGFloat = 40) {
    guard let viewportSize = geometry.viewportSize,
      let canvasSize = geometry.canvasSize
    else {
      print("Unable to calculate zoom to fit as viewport size is nil")
      return
    }
    /// Calculate available space after padding
    let availableWidth = viewportSize.width - (padding * 2)
    let availableHeight = viewportSize.height - (padding * 2)

    /// Calculate scale factors for each dimension
    let scaleX = availableWidth / canvasSize.width
    let scaleY = availableHeight / canvasSize.height

    /// Use the smaller scale to ensure content fits in both dimensions
    let newZoom = min(scaleX, scaleY)

    /// Apply the zoom, reset pan and rotation
    zoom = newZoom.clamped(to: zoomRange)
  }
}
