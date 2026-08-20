//
//  CanvasEventLifecycleTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 20/8/2026.
//

import SwiftUI
import Testing

@testable import CanvasKit

struct CanvasEventLifecycleTests {

  @Test(arguments: [CanvasToolID.select, .pan, .zoom])
  func hoverIsObservedWithEveryBuiltInTool(_ toolID: CanvasToolID) {
    let location = Point<ViewportSpace>(x: 24, y: 36)
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: toolID),
    )

    _ = handler.processedTransform(
      .hover(location),
      phase: .changed,
      modifiers: [],
    )

    #expect(handler.pointer.hover == location)
    #expect(handler.activeInteraction.contains(.hover))

    handler.endInteraction(.hover, phase: .ended, modifiers: [])

    #expect(handler.pointer.hover == nil)
    #expect(!handler.activeInteraction.contains(.hover))
    #expect(handler.latestInteraction.phase(for: .hover) == .ended)
  }

  @Test func toolClaimedHoverStillUpdatesGlobalObservation() {
    let location = Point<ViewportSpace>(x: 12, y: 18)
    let configuration = ToolConfiguration(
      tools: [HoverClaimingTool()],
      bindings: [],
    )
    let handler = CanvasHandler(toolConfiguration: configuration)

    let adjustment = handler.processedTransform(
      .hover(location),
      phase: .changed,
      modifiers: [],
    )

    #expect(adjustment == nil)
    #expect(handler.pointer.hover == location)
  }

  @Test func marqueePayloadPublishesEvenWhenToolNeedsNoPointerAdjustment() throws {
    let configuration = ToolConfiguration(
      tools: [MarqueeObservingTool()],
      bindings: [],
    )
    let handler = CanvasHandler(toolConfiguration: configuration)
    let payload = PointerDragPayload.rect(
      from: .init(x: 10, y: 20),
      current: .init(x: 30, y: 40),
    )

    _ = handler.processedTransform(
      .drag(payload),
      phase: .began,
      modifiers: [],
    )

    let event = try #require(handler.pointerDragEvent)
    #expect(event.start == Point<ViewportSpace>(x: 10, y: 20))
    #expect(event.current == Point<ViewportSpace>(x: 30, y: 40))
    #expect(event.phase == .began)
    #expect(handler.pointer.drag == nil)
  }

  @Test func continuousToolDragDoesNotPublishMarqueeEvent() {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .pan),
    )

    _ = handler.processedTransform(
      .drag(
        .delta(
          .init(width: 4, height: 6),
          location: .init(x: 30, y: 40),
        )
      ),
      phase: .began,
      modifiers: [],
    )

    #expect(handler.pointerDragEvent == nil)
  }

  @Test func reverseDragPreservesOrderedEndpointsAndDerivesBounds() {
    let event = CanvasDragEvent(
      start: .init(x: 40, y: 55),
      current: .init(x: 10, y: 15),
      phase: .changed,
    )

    #expect(event.start == Point<CanvasSpace>(x: 40, y: 55))
    #expect(event.current == Point<CanvasSpace>(x: 10, y: 15))
    #expect(event.boundingRect == Rect<CanvasSpace>(x: 10, y: 15, width: 30, height: 40))
  }

  @Test func dragEndpointsMapIndependentlyIntoCanvasSpace() {
    let mapper = CoordinateSpaceMapper(
      frame: .init(x: 100, y: 200, width: 400, height: 200),
      canvasSize: .init(width: 200, height: 100),
    )
    let viewportEvent = PointerDragEvent<ViewportSpace>(
      start: .init(x: 180, y: 260),
      current: .init(x: 140, y: 220),
      phase: .changed,
    )

    let event = CanvasDragEvent(event: viewportEvent, mapper: mapper)

    #expect(event.start == Point<CanvasSpace>(x: 40, y: 30))
    #expect(event.current == Point<CanvasSpace>(x: 20, y: 10))
    #expect(event.boundingRect == Rect<CanvasSpace>(x: 20, y: 10, width: 20, height: 20))
  }

  @Test func unchangedFinalDragGeometryStillProducesDistinctTerminalEvent() throws {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .select),
    )
    let payload = PointerDragPayload.rect(
      from: .init(x: 60, y: 50),
      current: .init(x: 20, y: 10),
    )

    _ = handler.processedTransform(
      .drag(payload),
      phase: .changed,
      modifiers: [],
    )
    let changed = try #require(handler.pointerDragEvent)

    _ = handler.processedTransform(
      .drag(payload),
      phase: .ended,
      modifiers: [],
    )
    let ended = try #require(handler.pointerDragEvent)

    #expect(changed.start == ended.start)
    #expect(changed.current == ended.current)
    #expect(changed.phase == .changed)
    #expect(ended.phase == .ended)
    #expect(changed != ended)
    #expect(handler.pointer.drag == nil)
    #expect(!handler.activeInteraction.contains(.drag))
  }

  @Test func cancellationTerminatesThePublishedDragWithoutLosingEndpoints() throws {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .select),
    )
    let payload = PointerDragPayload.rect(
      from: .init(x: 5, y: 10),
      current: .init(x: 25, y: 35),
    )

    _ = handler.processedTransform(
      .drag(payload),
      phase: .began,
      modifiers: [],
    )
    let active = try #require(handler.pointerDragEvent)

    handler.endInteraction(.drag, phase: .cancelled, modifiers: [])
    let cancelled = try #require(handler.pointerDragEvent)

    #expect(cancelled.start == active.start)
    #expect(cancelled.current == active.current)
    #expect(cancelled.phase == .cancelled)
    #expect(handler.pointer.drag == nil)
    #expect(!handler.activeInteraction.contains(.drag))

    handler.endInteraction(.drag, phase: .cancelled, modifiers: [])
    #expect(handler.pointerDragEvent == cancelled)
  }

  @Test func noneIsNotATerminalLifecycleEvent() {
    #expect(!InteractionPhase.none.isActive)
    #expect(!InteractionPhase.none.isTerminal)
    #expect(InteractionPhase.ended.isTerminal)
    #expect(InteractionPhase.cancelled.isTerminal)
  }
}

private struct HoverClaimingTool: CanvasTool {
  let id: CanvasToolID = "hover-claiming"
  let name = "Hover Claiming"
  let icon = "cursorarrow.motionlines"

  var dragConfiguration: PointerDragConfiguration { .marquee }
  var inputCapabilities: [ToolCapability] {
    [ToolCapability(interaction: .hover)]
  }

  func resolvePointerStyle(context: InteractionContext) -> CanvasPointerStyle {
    .default
  }

  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    .handled(.none)
  }
}

private struct MarqueeObservingTool: CanvasTool {
  let id: CanvasToolID = "marquee-observing"
  let name = "Marquee Observing"
  let icon = "rectangle.dashed"

  var dragConfiguration: PointerDragConfiguration { .marquee }
  var inputCapabilities: [ToolCapability] {
    [ToolCapability(interaction: .drag)]
  }

  func resolvePointerStyle(context: InteractionContext) -> CanvasPointerStyle {
    .default
  }

  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    .handled(.none)
  }
}
