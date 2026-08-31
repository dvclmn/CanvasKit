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

    _ = handler.processInteraction(
      .hover(location),
      phase: .changed,
      modifiers: [],
      zoomRange: Constants.zoomRange
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

    let adjustment = handler.processInteraction(
      .hover(location),
      phase: .changed,
      modifiers: [],
      zoomRange: Constants.zoomRange
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

    _ = handler.processInteraction(
      .drag(payload),
      phase: .began,
      modifiers: [],
      zoomRange: Constants.zoomRange
    )

    let event = try #require(handler.pointer.latestDrag)
    #expect(event.start == Point<ViewportSpace>(x: 10, y: 20))
    #expect(event.current == Point<ViewportSpace>(x: 30, y: 40))
    #expect(event.phase == .began)
  }

  @Test func modifierMismatchedMarqueeIsNeitherActiveNorPublished() {
    let handler = CanvasHandler(
      toolConfiguration: .init(tools: [ModifierMarqueeTool()], bindings: []),
    )
    let payload = PointerDragPayload.rect(
      from: .init(x: 10, y: 20),
      current: .init(x: 30, y: 40),
    )

    _ = handler.processInteraction(
      .drag(payload),
      phase: .began,
      modifiers: [],
      zoomRange: Constants.zoomRange
    )

    #expect(handler.pointer.latestDrag == nil)
    #expect(!handler.activeInteraction.contains(.drag))
  }

  @Test func repeatedTapAtSameLocationProducesDistinctSnapshots() throws {
    let handler = CanvasHandler(toolConfiguration: nil)
    let location = Point<ViewportSpace>(x: 25, y: 35)

    _ = handler.processInteraction(
      .tap(location: location),
      phase: .ended,
      modifiers: [],
      zoomRange: Constants.zoomRange
    )
    let first = try #require(handler.pointer.tap)

    _ = handler.processInteraction(
      .tap(location: location),
      phase: .ended,
      modifiers: [],
      zoomRange: Constants.zoomRange
    )
    let second = try #require(handler.pointer.tap)

    #expect(first.location == second.location)
    #expect(first.deliveryID != second.deliveryID)
    #expect(first != second)
  }

  @Test func activeDragTakesPointerStylePrecedenceOverHover() {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .pan),
    )

    _ = handler.processInteraction(
      .drag(.delta(.init(width: 4, height: 6), location: .init(x: 30, y: 40))),
      phase: .began,
      modifiers: [],
      zoomRange: Constants.zoomRange
    )
    #expect(handler.pointerStyle == .grabActive)

    _ = handler.processInteraction(
      .hover(.init(x: 32, y: 42)),
      phase: .changed,
      modifiers: [],
      zoomRange: Constants.zoomRange
    )
    #expect(handler.pointerStyle == .grabActive)

    handler.endInteraction(.drag, phase: .ended, modifiers: [])
    #expect(handler.pointerStyle == .grabIdle)
  }

  @Test func continuousToolDragDoesNotPublishMarqueeEvent() {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .pan),
    )

    _ = handler.processInteraction(
      .drag(
        .delta(
          .init(width: 4, height: 6),
          location: .init(x: 30, y: 40),
        )
      ),
      phase: .began,
      modifiers: [],
      zoomRange: Constants.zoomRange
    )

    #expect(handler.pointer.latestDrag == nil)
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
    let viewportEvent = PointerDragSnapshot<ViewportSpace>(
      start: .init(x: 180, y: 260),
      current: .init(x: 140, y: 220),
      phase: .changed,
      deliveryID: .init(sequence: 1),
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

    _ = handler.processInteraction(
      .drag(payload),
      phase: .changed,
      modifiers: [],
      zoomRange: Constants.zoomRange,
    )
    let changed = try #require(handler.pointer.latestDrag)

    _ = handler.processInteraction(
      .drag(payload),
      phase: .ended,
      modifiers: [],
      zoomRange: Constants.zoomRange
    )
    let ended = try #require(handler.pointer.latestDrag)

    #expect(changed.start == ended.start)
    #expect(changed.current == ended.current)
    #expect(changed.phase == .changed)
    #expect(ended.phase == .ended)
    #expect(changed.deliveryID != ended.deliveryID)
    #expect(changed != ended)
    #expect(!handler.activeInteraction.contains(.drag))
  }

  @Test func repeatedMarqueeSampleAtSameGeometryHasDistinctDeliveryIdentity() throws {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .select),
    )
    let payload = PointerDragPayload.rect(
      from: .init(x: 60, y: 50),
      current: .init(x: 20, y: 10),
    )

    _ = handler.processInteraction(
      .drag(payload),
      phase: .changed,
      modifiers: [],
      zoomRange: Constants.zoomRange,
    )
    let first = try #require(handler.pointer.latestDrag)

    _ = handler.processInteraction(
      .drag(payload),
      phase: .changed,
      modifiers: [],
      zoomRange: Constants.zoomRange,
    )
    let second = try #require(handler.pointer.latestDrag)

    #expect(first.start == second.start)
    #expect(first.current == second.current)
    #expect(first.phase == second.phase)
    #expect(first.deliveryID != second.deliveryID)
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

    _ = handler.processInteraction(
      .drag(payload),
      phase: .began,
      modifiers: [],
      zoomRange: Constants.zoomRange
    )
    let active = try #require(handler.pointer.latestDrag)

    handler.endInteraction(.drag, phase: .cancelled, modifiers: [])
    let cancelled = try #require(handler.pointer.latestDrag)

    #expect(cancelled.start == active.start)
    #expect(cancelled.current == active.current)
    #expect(cancelled.phase == .cancelled)
    #expect(cancelled.deliveryID != active.deliveryID)
    #expect(!handler.activeInteraction.contains(.drag))

    handler.endInteraction(.drag, phase: .cancelled, modifiers: [])
    #expect(handler.pointer.latestDrag == cancelled)
  }

  @Test func noneIsNotATerminalLifecycleEvent() {
    #expect(!InteractionPhase.none.isActive)
    #expect(!InteractionPhase.none.isTerminal)
    #expect(InteractionPhase.ended.isTerminal)
    #expect(InteractionPhase.cancelled.isTerminal)
  }

  @Test func mapperChangesReprojectRetainedEventsWithoutChangingDeliveryIdentity() throws {
    let tapDeliveryID = PointerEventDeliveryID(sequence: 41)
    let dragDeliveryID = PointerEventDeliveryID(sequence: 42)
    let pointerState = PointerState<ViewportSpace>(
      tap: .init(
        location: .init(x: 180, y: 260),
        deliveryID: tapDeliveryID,
      ),
      hover: nil,
      latestDrag: .init(
        start: .init(x: 180, y: 260),
        current: .init(x: 140, y: 220),
        phase: .ended,
        deliveryID: dragDeliveryID,
      ),
    )
    let initialMapper = CoordinateSpaceMapper(
      frame: .init(x: 100, y: 200, width: 400, height: 200),
      canvasSize: .init(width: 200, height: 100),
    )
    let pannedMapper = CoordinateSpaceMapper(
      frame: .init(x: 140, y: 220, width: 400, height: 200),
      canvasSize: .init(width: 200, height: 100),
    )

    let initial = PointerMappedSnapshot.createMapped(
      mapper: initialMapper,
      pointerState: pointerState,
    )
    let panned = PointerMappedSnapshot.createMapped(
      mapper: pannedMapper,
      pointerState: pointerState,
    )

    let initialTap = try #require(initial.tap)
    let pannedTap = try #require(panned.tap)
    #expect(initialTap.value != pannedTap.value)
    #expect(initialTap.deliveryID == pannedTap.deliveryID)
    #expect(initialTap == pannedTap)

    let initialDrag = try #require(initial.drag)
    let pannedDrag = try #require(panned.drag)
    #expect(initialDrag.value != pannedDrag.value)
    #expect(initialDrag.deliveryID == pannedDrag.deliveryID)
    #expect(initialDrag == pannedDrag)
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
    .consumed
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
    .consumed
  }
}

private struct ModifierMarqueeTool: CanvasTool {
  let id: CanvasToolID = "modifier-marquee"
  let name = "Modifier Marquee"
  let icon = "rectangle.dashed"

  var dragConfiguration: PointerDragConfiguration { .marquee }
  var inputCapabilities: [ToolCapability] {
    [ToolCapability(interaction: .drag, intent: .select, modifiers: [.option])]
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
