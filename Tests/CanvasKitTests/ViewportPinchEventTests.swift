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

    let emittedEvent = accumulator.changed(magnification: 1.25)
    let event = try #require(emittedEvent)

    #expect(event.magnification == 1.25)
    #expect(event.magnificationDelta == 1.25)
    #expect(event.phase == .began)
  }

  @Test func subsequentEventsUsePreviousMagnification() throws {
    var accumulator = ViewportPinchEventAccumulator()
    _ = accumulator.changed(magnification: 1.25)

    let emittedEvent = accumulator.changed(magnification: 1.5)
    let event = try #require(emittedEvent)

    #expect(event.magnification == 1.5)
    #expect(isNear(event.magnificationDelta, 1.2))
    #expect(event.phase == .changed)
  }

  @Test func reciprocalGesturesProduceReciprocalDeltas() throws {
    var outwardAccumulator = ViewportPinchEventAccumulator()
    var inwardAccumulator = ViewportPinchEventAccumulator()

    let emittedOutward = outwardAccumulator.changed(magnification: 1.25)
    let outward = try #require(emittedOutward)
    let emittedInward = inwardAccumulator.changed(magnification: 0.8)
    let inward = try #require(emittedInward)

    #expect(isNear(outward.magnificationDelta * inward.magnificationDelta, 1))
  }

  @Test func newGestureRestartsFromIdentity() throws {
    var accumulator = ViewportPinchEventAccumulator()
    _ = accumulator.changed(magnification: 1.5)
    _ = accumulator.ended(magnification: 1.5)

    let emittedEvent = accumulator.changed(magnification: 0.75)
    let event = try #require(emittedEvent)

    #expect(event.magnificationDelta == 0.75)
    #expect(event.phase == .began)
  }

  @Test func invalidChangedInputIsNotEmittedOrRetained() throws {
    var accumulator = ViewportPinchEventAccumulator()

    #expect(accumulator.changed(magnification: .nan) == nil)
    #expect(accumulator.changed(magnification: .infinity) == nil)
    #expect(accumulator.changed(magnification: 0) == nil)
    #expect(accumulator.changed(magnification: -1) == nil)

    let emittedEvent = accumulator.changed(magnification: 1.2)
    let event = try #require(emittedEvent)

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

    let emittedEvent = accumulator.ended(magnification: .nan)
    let event = try #require(emittedEvent)

    #expect(event.magnification == 1.2)
    #expect(event.magnificationDelta == 1)
    #expect(event.phase == .ended)
  }

  @Test func terminalEventIncludesOnlyUnemittedFinalChange() throws {
    var accumulator = ViewportPinchEventAccumulator()
    _ = accumulator.changed(magnification: 1.2)

    let emittedUnchanged = accumulator.ended(magnification: 1.2)
    let unchanged = try #require(emittedUnchanged)

    #expect(unchanged.magnificationDelta == 1)

    _ = accumulator.changed(magnification: 1.2)
    let emittedChanged = accumulator.ended(magnification: 1.5)
    let changed = try #require(emittedChanged)

    #expect(isNear(changed.magnificationDelta, 1.25))
  }

  @Test func resetClearsTransientGestureState() throws {
    var accumulator = ViewportPinchEventAccumulator()
    _ = accumulator.changed(magnification: 1.5)

    accumulator.reset()

    #expect(!accumulator.isActive)
    #expect(accumulator.previousMagnification == 1)

    let emittedEvent = accumulator.changed(magnification: 1.1)
    let event = try #require(emittedEvent)
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
