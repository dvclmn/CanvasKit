//
//  CanvasInputResolverTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/5/2026.
//

import GeometryPrimitives
import InputPrimitives
import SwiftUI
import Testing

@testable import CanvasKit

struct CanvasInputResolverTests {

  @Test func pinchDefaultUsesProvidedScaleAsAbsoluteZoomLevel() {
    let currentTransform = TransformState(scale: 2)
    let context = InteractionContext(
      interaction: .pinch(scale: 2.2),
      phase: .changed,
      modifiers: [],
    )

    let adjustment = CanvasInputResolver.defaultResolution(
      for: context,
      currentTransform: currentTransform,
    )

    #expect(isNear(resolvedScale(from: adjustment), 2.2))
  }

  @Test func zoomAdjustmentStillAppliesMultiplicativeFactor() {
    let transform = TransformState(scale: 2)
    let adjustment = TransformAdjustment.zoomAdjustment(
      for: transform,
      by: 1.25,
    )

    guard case .scale(let scale) = adjustment else {
      Issue.record("Expected zoom adjustment to produce a scale transform")
      return
    }

    #expect(isNear(scale, 2.5))
  }

  @Test func optionSwipeDefaultsToZoomAdjustment() {
    let context = InteractionContext(
      interaction: .swipe(delta: Size<ScreenSpace>(width: 0, height: 20)),
      phase: .changed,
      modifiers: [.option],
    )

    let adjustment = CanvasInputResolver.defaultResolution(
      for: context,
      currentTransform: TransformState(scale: 2),
    )

    #expect(isNear(resolvedScale(from: adjustment), 2.2))
  }

  @Test func hoverDefaultsToPointerTrackingWhenNoToolClaimsIt() {
    let location = Point<ScreenSpace>(fromPoint: .zero)
    let context = InteractionContext(
      interaction: .hover(location),
      phase: .changed,
      modifiers: [],
    )

    let adjustment = CanvasInputResolver.defaultResolution(
      for: context,
      currentTransform: .identity,
    )

    guard case .pointer(.hover(let resolvedLocation)) = adjustment else {
      Issue.record("Expected hover to update pointer tracking by default")
      return
    }
    #expect(resolvedLocation == location)
  }
}

private func resolvedScale(from adjustment: InteractionAdjustment?) -> Double? {
  guard case .transform(.scale(let scale)) = adjustment else { return nil }
  return scale
}

private func isNear(
  _ actual: Double?,
  _ expected: Double,
  tolerance: Double = 0.0001,
) -> Bool {
  guard let actual else { return false }
  return abs(actual - expected) <= tolerance
}
