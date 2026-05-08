//
//  PinchZoomComputationTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 8/5/2026.
//

import Testing

@testable import CanvasKit

struct PinchZoomComputationTests {

  @Test func proposedZoomIsAnchoredToGestureStart() {
    let proposed = PinchZoomComputation.proposedZoom(
      startZoom: 2,
      magnification: 0.5,
    )

    #expect(isNear(proposed, 1))
  }

  @Test func proposedZoomDoesNotCompoundFromPreviousCommittedZoom() {
    let gestureStartZoom = 1.0

    let zoomedOut = PinchZoomComputation.proposedZoom(
      startZoom: gestureStartZoom,
      magnification: 0.5,
    )
    let zoomedBackIn = PinchZoomComputation.proposedZoom(
      startZoom: gestureStartZoom,
      magnification: 0.75,
    )

    #expect(isNear(zoomedOut, 0.5))
    #expect(isNear(zoomedBackIn, 0.7071))
  }

  @Test func defaultResponseMapsSymmetricPinchesToReciprocalZoomFactors() {
    let zoomOutFactor = PinchZoomComputation.responseFactor(0.5)
    let zoomInFactor = PinchZoomComputation.responseFactor(1.5)

    #expect(isNear(zoomOutFactor, 0.5))
    #expect(isNear(zoomInFactor, 2))
    #expect(isNear(zoomOutFactor * zoomInFactor, 1))
  }

  @Test func sensitivityCanTuneMagnificationCurve() {
    let gentle = PinchZoomComputation.responseFactor(0, sensitivity: 0)
    let standard = PinchZoomComputation.responseFactor(0, sensitivity: 0.5)
    let strong = PinchZoomComputation.responseFactor(0, sensitivity: 1)

    #expect(isNear(gentle, 0.5))
    #expect(isNear(standard, 0.25))
    #expect(isNear(strong, 0.125))
  }

  @Test func invalidInputFallsBackToIdentityMagnification() {
    let proposed = PinchZoomComputation.proposedZoom(
      startZoom: 2,
      magnification: .nan,
    )

    #expect(isNear(proposed, 2))
  }

  @Test func zeroMagnificationSaturatesInsteadOfResettingToGestureStart() {
    let proposed = PinchZoomComputation.proposedZoom(
      startZoom: 2,
      magnification: 0,
    )

    #expect(isNear(proposed, 0.5))
  }
}

private func isNear(
  _ actual: Double,
  _ expected: Double,
  tolerance: Double = 0.0001,
) -> Bool {
  abs(actual - expected) <= tolerance
}
