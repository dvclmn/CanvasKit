//
//  ViewportPinchEventTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 30/7/2026.
//

import Testing

@testable import CanvasKit

struct ViewportPinchEventTests {

  @Test func firstEventRetainsDeltaFromIdentity() throws {
    var accumulator = ViewportPinchEventAccumulator()

    let event = try #require(
      accumulator.changed(magnification: 1.25)
    )

    #expect(event.magnification == 1.25)
    #expect(event.magnificationDelta == 1.25)
    #expect(event.phase == .began)
  }

  @Test func subsequentEventsUsePreviousMagnification() throws {
    var accumulator = ViewportPinchEventAccumulator()
    _ = accumulator.changed(magnification: 1.25)

    let event = try #require(
      accumulator.changed(magnification: 1.5)
    )

    #expect(event.magnification == 1.5)
    #expect(isNear(event.magnificationDelta, 1.2))
    #expect(event.phase == .changed)
  }

  @Test func reciprocalGesturesProduceReciprocalDeltas() throws {
    var outwardAccumulator = ViewportPinchEventAccumulator()
    var inwardAccumulator = ViewportPinchEventAccumulator()

    let outward = try #require(
      outwardAccumulator.changed(magnification: 1.25)
    )
    let inward = try #require(
      inwardAccumulator.changed(magnification: 0.8)
    )

    #expect(isNear(outward.magnificationDelta * inward.magnificationDelta, 1))
  }

  @Test func newGestureRestartsFromIdentity() throws {
    var accumulator = ViewportPinchEventAccumulator()
    _ = accumulator.changed(magnification: 1.5)
    _ = accumulator.ended(magnification: 1.5)

    let event = try #require(
      accumulator.changed(magnification: 0.75)
    )

    #expect(event.magnificationDelta == 0.75)
    #expect(event.phase == .began)
  }

  @Test func invalidChangedInputIsNotEmittedOrRetained() throws {
    var accumulator = ViewportPinchEventAccumulator()

    #expect(accumulator.changed(magnification: .nan) == nil)
    #expect(accumulator.changed(magnification: .infinity) == nil)
    #expect(accumulator.changed(magnification: 0) == nil)
    #expect(accumulator.changed(magnification: -1) == nil)

    let event = try #require(
      accumulator.changed(magnification: 1.2)
    )

    #expect(event.magnificationDelta == 1.2)
    #expect(event.phase == .began)
  }

  @Test func nonFiniteComputedDeltaIsNotEmitted() {
    var accumulator = ViewportPinchEventAccumulator()
    _ = accumulator.changed(magnification: .leastNonzeroMagnitude)

    let event = accumulator.changed(
      magnification: .greatestFiniteMagnitude
    )

    #expect(event == nil)
    #expect(accumulator.previousMagnification == .leastNonzeroMagnitude)
  }

  @Test func invalidTerminalInputUsesIdentityDelta() throws {
    var accumulator = ViewportPinchEventAccumulator()
    _ = accumulator.changed(magnification: 1.2)

    let event = try #require(
      accumulator.ended(magnification: .nan)
    )

    #expect(event.magnification == 1.2)
    #expect(event.magnificationDelta == 1)
    #expect(event.phase == .ended)
  }

  @Test func terminalEventIncludesOnlyUnemittedFinalChange() throws {
    var accumulator = ViewportPinchEventAccumulator()
    _ = accumulator.changed(magnification: 1.2)

    let unchanged = try #require(
      accumulator.ended(magnification: 1.2)
    )

    #expect(unchanged.magnificationDelta == 1)

    _ = accumulator.changed(magnification: 1.2)
    let changed = try #require(
      accumulator.ended(magnification: 1.5)
    )

    #expect(isNear(changed.magnificationDelta, 1.25))
  }

  @Test func resetClearsTransientGestureState() throws {
    var accumulator = ViewportPinchEventAccumulator()
    _ = accumulator.changed(magnification: 1.5)

    accumulator.reset()

    #expect(!accumulator.isActive)
    #expect(accumulator.previousMagnification == 1)

    let event = try #require(
      accumulator.changed(magnification: 1.1)
    )
    #expect(event.magnificationDelta == 1.1)
    #expect(event.phase == .began)
  }
}

private func isNear(
  _ actual: Double,
  _ expected: Double,
  tolerance: Double = 0.0001,
) -> Bool {
  abs(actual - expected) <= tolerance
}
