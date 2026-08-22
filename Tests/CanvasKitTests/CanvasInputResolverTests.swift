//
//  CanvasInputResolverTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/5/2026.
//

import SwiftUI
import Testing

@testable import CanvasKit

struct CanvasInputResolverTests {

  @Test func pinchDefaultUsesProvidedScaleAsAbsoluteZoomLevel() {
    let context = InteractionContext(
      interaction: .pinch(scale: 2.2),
      phase: .changed,
      modifiers: [],
    )

    let adjustment = CanvasInputResolver.defaultResolution(
      for: context,
      currentTransform: TransformState(scale: 2),
    )

    #expect(isNear(resolvedScale(from: adjustment), 2.2))
  }

  @Test func optionSwipeDefaultsToZoomAdjustment() {
    let context = InteractionContext(
      interaction: .swipe(delta: Size<ViewportSpace>(width: 0, height: 20)),
      phase: .changed,
      modifiers: [.option],
    )

    let adjustment = CanvasInputResolver.defaultResolution(
      for: context,
      currentTransform: TransformState(scale: 2),
    )

    #expect(isNear(resolvedScale(from: adjustment), 2.2))
  }

  @Test func mostSpecificCapabilitySuppliesToolIntent() {
    let context = InteractionContext(
      interaction: marqueeInteraction,
      phase: .began,
      modifiers: [.option, .shift],
    )
    let resolver = CanvasInputResolver(
      context: context,
      effectiveTool: IntentRoutingTool(),
      transform: .identity,
    )

    #expect(resolvedScale(from: resolver.resolve()) == 3)
  }

  @Test func equalSpecificityPreservesCapabilityDeclarationOrder() throws {
    let context = InteractionContext(
      interaction: marqueeInteraction,
      phase: .began,
      modifiers: [.option],
    )
    let capabilities = [
      ToolCapability(interaction: .drag, intent: .pan, modifiers: [.option]),
      ToolCapability(interaction: .drag, intent: .zoom, modifiers: [.option]),
    ]

    let match = try #require(capabilities.bestMatch(for: context))
    #expect(match.intent == .pan)
  }

  @Test func missingRequiredModifiersLeavePointerDragUnresolved() {
    let context = InteractionContext(
      interaction: marqueeInteraction,
      phase: .began,
      modifiers: [],
    )
    let resolver = CanvasInputResolver(
      context: context,
      effectiveTool: OptionMarqueeTool(),
      transform: .identity,
    )

    #expect(resolver.resolve() == nil)
  }

  @Test func activeDragRetainsItsInitiallyResolvedIntent() {
    let handler = CanvasHandler(
      toolConfiguration: .init(tools: [IntentRoutingTool()], bindings: []),
    )

    _ = handler.processInteraction(
      marqueeInteraction,
      phase: .began,
      modifiers: [.option],
    )
    #expect(handler.pointerStyleContext?.intent == .zoom)

    _ = handler.processInteraction(
      marqueeInteraction,
      phase: .changed,
      modifiers: [],
    )
    #expect(handler.pointerStyleContext?.intent == .zoom)
  }
}

private let marqueeInteraction = Interaction.drag(
  .rect(
    from: .init(x: 10, y: 20),
    current: .init(x: 30, y: 40),
  )
)

private struct IntentRoutingTool: CanvasTool {
  let id: CanvasToolID = "intent-routing"
  let name = "Intent Routing"
  let icon = "arrow.triangle.branch"

  var dragConfiguration: PointerDragConfiguration { .marquee }
  var inputCapabilities: [ToolCapability] {
    [
      ToolCapability(interaction: .drag, intent: .pan),
      ToolCapability(interaction: .drag, intent: .zoom, modifiers: [.option]),
      ToolCapability(
        interaction: .drag,
        intent: .drawMarquee,
        modifiers: [.option, .shift],
      ),
    ]
  }

  func resolvePointerStyle(context: InteractionContext) -> CanvasPointerStyle {
    .default
  }

  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    let scale = switch context.intent {
      case .pan: 1.0
      case .zoom: 2.0
      case .drawMarquee: 3.0
      default: 0.0
    }
    return .handled(.transform(.scale(scale)))
  }
}

private struct OptionMarqueeTool: CanvasTool {
  let id: CanvasToolID = "option-marquee"
  let name = "Option Marquee"
  let icon = "rectangle.dashed"

  var dragConfiguration: PointerDragConfiguration { .marquee }
  var inputCapabilities: [ToolCapability] {
    [ToolCapability(interaction: .drag, intent: .drawMarquee, modifiers: [.option])]
  }

  func resolvePointerStyle(context: InteractionContext) -> CanvasPointerStyle {
    .default
  }

  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    .consumed
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
