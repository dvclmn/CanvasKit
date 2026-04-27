//
//  CanvasConstants.swift
//  CanvasKit
//
//  Created by Dave Coleman on 27/4/2026.
//

extension CanvasHandler {
  enum Constants {
    static let minZoomLowerBound: Double = 0.05
    static let minZoomUpperBound: Double = 40
    static var zoomRangeConstrained: ClosedRange<Double> {
      Self.minZoomLowerBound...Self.minZoomUpperBound
    }
  }
}
