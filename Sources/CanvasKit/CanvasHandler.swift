//
//  CanvasHandler.swift
//  CanvasKit
//
//  Created by Dave Coleman on 8/3/2026.
//

private import CoreTools
import SwiftUI

@Observable
final class CanvasHandler {

  var toolHandler: ToolHandler
  var pointer: PointerState<ViewportSpace> = .init()
  private var pointerEventSequence: UInt64 = 0

  /// The rich interaction context retained to resolve the current pointer style.
  ///
  /// This is the most recently processed context whose payload and modifiers are
  /// useful to the effective tool. It is not an interaction history: ending a
  /// different interaction kind does not replace this context merely to record
  /// that lifecycle event. Use ``latestInteraction`` to observe the most recent
  /// interaction kind and phase.
  var pointerStyleContext: InteractionContext?

  /// The most recently observed accepted interaction lifecycle event.
  ///
  /// This compact diagnostic snapshot records only the interaction kind and
  /// phase. Unlike ``activeInteraction``, it retains terminal events such as
  /// an ended hover or cancelled drag after that kind has ceased to be active.
  /// Unlike ``pointerStyleContext``, it intentionally does not retain an
  /// interaction payload or modifier state.
  var latestInteraction: InteractionSnapshot = .none

  /// The current active interaction contexts, indexed by interaction kind.
  ///
  /// A context is present only while its phase is active. Terminal phases remove
  /// only their matching kind, allowing overlapping interactions, such as a
  /// pinch and hover, to remain independently represented. This is the source
  /// for ``activeInteraction``; it cannot represent the most recent completed
  /// interaction.
  private var activeContextsByKind: [Interaction.Kind: InteractionContext] = [:]

  /// Consumer-facing projection of the kinds currently active in the canvas.
  ///
  /// This stored value changes only when membership in ``activeContextsByKind``
  /// changes. Updates to an already-active context therefore do not republish
  /// per-event payload changes through the SwiftUI Environment.
  private(set) var canvasInteractionActivity: CanvasInteractionActivity = .none

  var artworkFrame: Rect<ViewportSpace>?
  var currentTransform: TransformState = .identity

  var measuredCanvasSize: Size<CanvasSpace>?

  init(
    toolConfiguration: ToolConfiguration?,
    toolSelection: ToolSelection? = nil,
    currentTransform: TransformState = .identity,
  ) {
    self.toolHandler = .init(
      configuration: toolConfiguration,
      selection: toolSelection,
    )
    self.currentTransform = currentTransform
  }
}

extension CanvasHandler {

  /// Processes one raw input update from CanvasKit's gesture modifiers.
  ///
  /// Global hover location is recorded independently of tool resolution so
  /// public observation does not disappear when a tool claims hover. A tool
  /// with a matching capability may still resolve that hover for its own
  /// canvas adjustment or pointer style.
  ///
  /// Claimed interactions are forwarded to the effective tool's
  /// ``CanvasTool/resolveInteraction(context:currentTransform:)`` method.
  ///
  /// Returns the proposed transform only when resolution produced a transform
  /// adjustment. Pointer observations and consumed interactions return `nil`,
  /// preventing ``InteractionModifiers`` from writing an identity transform.
  @discardableResult
  func processInteraction(
    _ interaction: Interaction,
    phase: InteractionPhase,
    modifiers: EventModifiers,
    zoomRange: ClosedRange<Double>,
  ) -> TransformState? {

    let unresolvedContext = InteractionContext(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
    )

    guard let context = routedContext(for: unresolvedContext) else {
      return nil
    }

    recordAcceptedInteraction(context)

    let adjustment = resolvedAdjustment(for: context)
    let committedTransform = applyResolvedAdjustment(
      adjustment,
      zoomRange: zoomRange,
    )

    recordPublicPointerInput(from: context)
    return committedTransform

  }
}

extension CanvasHandler {
  private func recordAcceptedInteraction(
    _ context: InteractionContext
  ) {
    pointerStyleContext = context
    latestInteraction = .init(context: context)
    updateActiveInteraction(with: context)
  }

  private func resolvedAdjustment(
    for context: InteractionContext
  ) -> InteractionAdjustment? {
    CanvasInputResolver(
      context: context,
      effectiveTool: effectiveTool,
      transform: currentTransform,
    ).resolve()
  }

  private func applyResolvedAdjustment(
    _ adjustment: InteractionAdjustment?,
    zoomRange: ClosedRange<Double>,
  ) -> TransformState? {
    guard let adjustment else { return nil }

    switch adjustment {
      case .transform(let adjustment):
        var nextTransform = adjustment.updatedState(currentTransform)
        nextTransform.scale = nextTransform.scale.clamped(to: zoomRange)

        currentTransform = nextTransform
        return nextTransform

      case .pointer(let adjustment):
        applyPointerAdjustment(adjustment)
        return nil

      case .none:
        return nil
    }
  }

  private func applyPointerAdjustment(
    _ adjustment: PointerAdjustment
  ) {
    switch adjustment {
      case .tap(let point):
        recordTap(at: point)

      case .hover(let point):
        pointer.hover = point
    }
  }

  private func recordPublicPointerInput(from context: InteractionContext) {
    switch context.interaction {
      case .hover(let location):
        pointer.hover = location

      case .drag(let payload):
        recordPublishedDrag(payload, phase: context.phase)

      default:
        break
    }
  }

  private func recordPublishedDrag(
    _ payload: PointerDragPayload,
    phase: InteractionPhase,
  ) {
    guard case .rect = payload else { return }

    guard
      let event = PointerDragSnapshot<ViewportSpace>(
        payload: payload,
        phase: phase,
        deliveryID: nextPointerEventDeliveryID(),
      )
    else { return }

    pointer.latestDrag = event
  }

  private func recordTap(at location: Point<ViewportSpace>) {
    pointer.tap = .init(
      location: location,
      deliveryID: nextPointerEventDeliveryID(),
    )
  }

  private func nextPointerEventDeliveryID() -> PointerEventDeliveryID {
    pointerEventSequence &+= 1
    return .init(sequence: pointerEventSequence)
  }

  /// Resolves tool meaning before state or public events are recorded.
  ///
  /// Tap and drag are admitted only when the effective tool has a matching
  /// capability. An active drag retains its initially matched capability so a
  /// modifier change cannot silently reinterpret the gesture halfway through.
  /// Global interactions remain eligible for CanvasKit default handling even
  /// when no tool capability matches.
  private func routedContext(
    for context: InteractionContext
  ) -> InteractionContext? {
    if context.interaction.kind == .drag,
      let activeCapability = activeContextsByKind[.drag]?.matchedCapability
    {
      return context.matching(activeCapability)
    }

    let resolvedContext = CanvasInputResolver(
      context: context,
      effectiveTool: effectiveTool,
      transform: currentTransform,
    ).resolvedContext()

    switch context.interaction.kind {
      case .tap, .drag:
        guard resolvedContext.matchedCapability != nil else { return nil }
      case .swipe, .pinch, .rotate, .hover:
        break
    }

    return resolvedContext
  }

  func endInteraction(
    _ kind: Interaction.Kind,
    phase: InteractionPhase,
    modifiers: EventModifiers,
  ) {
    latestInteraction = .init(kind: kind, phase: phase)
    setActiveContext(nil, for: kind)

    if let context = pointerStyleContext,
      context.interaction.kind == kind
    {
      pointerStyleContext =
        context
        .withPhase(phase)
        .withModifiers(modifiers)
    }

    if kind == .hover {
      pointer.hover = nil
    }

    if kind == .drag {
      finishPublishedDrag(with: phase)
    }
  }

  private func finishPublishedDrag(with phase: InteractionPhase) {
    guard phase.isTerminal,
      let event = pointer.latestDrag,
      event.phase.isActive
    else { return }

    pointer.latestDrag = event.withPhase(
      phase,
      deliveryID: nextPointerEventDeliveryID(),
    )
  }

  private func updateActiveInteraction(with context: InteractionContext) {
    let kind = context.interaction.kind
    setActiveContext(context.phase.isActive ? context : nil, for: kind)
  }

  private func setActiveContext(
    _ context: InteractionContext?,
    for kind: Interaction.Kind,
  ) {
    let wasActive = activeContextsByKind[kind] != nil
    activeContextsByKind[kind] = context

    guard wasActive != (context != nil) else { return }
    canvasInteractionActivity = .init(
      activeKinds: Set(activeContextsByKind.keys)
    )
  }
}

extension CanvasHandler {

  func coordinateSpaceMapper(in size: Size<CanvasSpace>?) -> CoordinateSpaceMapper? {
    guard let artworkFrame,
      let resolvedSize = resolvedCanvasSize(for: size)
    else { return nil }
    return .init(frame: artworkFrame, canvasSize: resolvedSize)
  }

  func resolvedCanvasSize(for size: Size<CanvasSpace>?) -> Size<CanvasSpace>? {
    size ?? measuredCanvasSize
  }

  var activeInteraction: ActiveInteraction {
    guard !activeContextsByKind.isEmpty else { return .none }
    return .init(contextsByKind: activeContextsByKind)
  }

  /// The runtime tool used to resolve canvas input right now.
  ///
  /// This includes transient overrides such as Space-held Pan. For the
  /// committed/base selection only, use `toolHandler.committedTool`.
  var effectiveTool: any CanvasTool { toolHandler.effectiveTool }

  /// The committed selection synchronised with an optional parent binding.
  ///
  /// With no tool configuration, CanvasKit's fallback Select tool is the only
  /// valid committed selection.
  var committedToolSelection: ToolSelection {
    get { toolHandler.selection ?? .default }
    set { toolHandler.synchroniseCommittedSelection(newValue) }
  }

}

extension CanvasHandler {
  func updateModifiers(_ modifiers: EventModifiers) {
    toolHandler.updateModifiers(modifiers)
    pointerStyleContext = pointerStyleContext?.withModifiers(modifiers)
    activeContextsByKind = activeContextsByKind.mapValues { context in
      context.withModifiers(modifiers)
    }
  }

  var pointerStyle: CanvasPointerStyle? {
    let context = activeContextsByKind[.drag] ?? pointerStyleContext
    guard let context else { return nil }

    let resolvedContext = CanvasInputResolver(
      context: context,
      effectiveTool: effectiveTool,
      transform: currentTransform,
    ).resolvedContext()

    return effectiveTool.resolvePointerStyle(context: resolvedContext)
  }

}
