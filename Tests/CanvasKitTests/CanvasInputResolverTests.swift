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
