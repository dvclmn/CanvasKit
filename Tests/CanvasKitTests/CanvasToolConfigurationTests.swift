//
//  CanvasToolConfigurationTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 25/2/2026.
//

import Foundation
import InputPrimitives
import SwiftUI
import Testing

@testable import CanvasKit

extension CanvasToolKind {
  static let brush = Self("brush")
}

struct ToolConfigurationTests {

  @Test func initialSelectionDefaultsToFirstRegisteredTool() {
    let configuration = ToolConfiguration(
      tools: [BrushTool(), SelectTool(), ZoomTool()],
      bindings: [],
    )

    #expect(configuration.selectedToolKind == .brush)
    #expect(configuration.defaultToolKind == .brush)
    #expect(configuration.resolvedSelectionKind == .brush)
  }

  @Test func invalidInitialSelectionNormalisesToDefaultTool() {
    let configuration = ToolConfiguration(
      tools: [BrushTool(), SelectTool()],
      bindings: [],
      selectedToolKind: .zoom,
    )

    #expect(configuration.selectedToolKind == .brush)
    #expect(configuration.isSelectionValid)
  }

  @Test func duplicateToolKindsKeepFirstPositionButReplaceValue() {
    let configuration = ToolConfiguration(
      tools: [SelectTool(), CustomZoomTool(name: "Zoom A"), BrushTool(), CustomZoomTool(name: "Zoom B")],
      bindings: [],
    )

    #expect(configuration.tools.map(\.kind) == [.select, .zoom, .brush])
    #expect(configuration.tool(for: .zoom)?.name == "Zoom B")
  }

  @Test func selectingMissingToolDoesNothing() {
    var configuration = ToolConfiguration(
      tools: [SelectTool(), BrushTool()],
      bindings: [],
      selectedToolKind: .brush,
    )

    configuration.select(.zoom)

    #expect(configuration.selectedToolKind == .brush)
  }

  @Test func invalidAndDuplicateBindingsAreSurfacedSeparatelyFromActiveBindings() {
    let configuration = ToolConfiguration(
      tools: [SelectTool(), BrushTool()],
      bindings: [
        .init(.keyOnly("v"), target: .select, mode: .sticky),
        .init(.keyOnly("v"), target: .brush, mode: .sticky),
        .init(.keyOnly("z"), target: .zoom, mode: .sticky),
      ],
    )

    #expect(configuration.activeBindings.map(\.target) == [.select, .brush])
    #expect(configuration.invalidBindings.map(\.target) == [.zoom])
    #expect(configuration.duplicateBindings.map(\.target) == [.brush])
  }

  @Test func setToolsNormalisesOrderAndRepairsSelection() {
    var configuration = ToolConfiguration(
      tools: [SelectTool(), ZoomTool()],
      bindings: [],
      selectedToolKind: .zoom,
    )

    configuration.setTools([BrushTool(), CustomZoomTool(name: "Zoom B"), BrushTool()])

    #expect(configuration.tools.map(\.kind) == [.brush, .zoom])
    #expect(configuration.selectedToolKind == .zoom)

    configuration.setTools([BrushTool()])

    #expect(configuration.selectedToolKind == .brush)
    #expect(configuration.resolvedSelectedTool.kind == .brush)
  }

  @Test func moveToolReordersExistingToolOnly() {
    var configuration = ToolConfiguration(
      tools: [SelectTool(), BrushTool(), ZoomTool()],
      bindings: [],
    )

    configuration.moveTool(kind: .zoom, to: 0)
    #expect(configuration.tools.map(\.kind) == [.zoom, .select, .brush])

    configuration.moveTool(kind: .pan, to: 1)
    #expect(configuration.tools.map(\.kind) == [.zoom, .select, .brush])
  }
}

struct ToolHandlerTests {

  @Test func handlerIgnoresBindingTargetsThatAreNotRegistered() {
    let configuration = ToolConfiguration(
      tools: [SelectTool()],
      bindings: [
        .init(.keyOnly("z"), target: .zoom, mode: .sticky)
      ],
    )
    let handler = ToolHandler()
    handler.configuration = configuration

    handler.handleKeyDown("z")

    #expect(handler.toolKind == .select)
    #expect(handler.overrides.isEmpty)
  }

  @Test func bindingPrecedencePrefersExactModifierMatchThenMostSpecificSubset() {
    let configuration = ToolConfiguration(
      tools: [SelectTool(), BrushTool(), ZoomTool()],
      bindings: [
        .init(KeyboardShortcut("b", modifiers: []), target: .select, mode: .sticky),
        .init(KeyboardShortcut("b", modifiers: [.shift]), target: .brush, mode: .sticky),
        .init(KeyboardShortcut("b", modifiers: [.shift, .command]), target: .zoom, mode: .sticky),
      ],
      selectedToolKind: .select,
    )
    let handler = ToolHandler()
    handler.configuration = configuration

    handler.updateModifiers([.shift, .command])
    handler.handleKeyDown("b")
    #expect(handler.effectiveTool.kind == .zoom)
    handler.handleKeyUp("b")
    #expect(handler.configuration.selectedToolKind == .zoom)

    handler.configuration.select(.select)
    handler.updateModifiers([.shift])
    handler.handleKeyDown("b")
    #expect(handler.effectiveTool.kind == .brush)
    handler.handleKeyUp("b")
    #expect(handler.configuration.selectedToolKind == .brush)
  }

  @Test func stickyShortPressCommitsSelection() {
    let configuration = ToolConfiguration(
      tools: [SelectTool(), BrushTool()],
      bindings: [
        .init(.keyOnly("b"), target: .brush, mode: .sticky)
      ],
      selectedToolKind: .select,
      springLoadDelay: 0.2,
    )
    let handler = ToolHandler()
    handler.configuration = configuration

    handler.handleKeyDown("b")
    #expect(handler.effectiveTool.kind == .brush)
    #expect(handler.isSpringLoaded == false)

    handler.handleKeyUp("b")

    #expect(handler.configuration.selectedToolKind == .brush)
    #expect(handler.overrides.isEmpty)
  }

  @Test func stickyLongHoldSpringLoadsThenReverts() {
    let configuration = ToolConfiguration(
      tools: [SelectTool(), BrushTool()],
      bindings: [
        .init(.keyOnly("b"), target: .brush, mode: .sticky)
      ],
      selectedToolKind: .select,
      springLoadDelay: 0.01,
    )
    let handler = ToolHandler()
    handler.configuration = configuration

    handler.handleKeyDown("b")
    Thread.sleep(forTimeInterval: 0.02)
    handler.armSpringLoadsIfReady()

    #expect(handler.springLoadedTool?.kind == .brush)
    #expect(handler.isSpringLoaded)

    handler.handleKeyUp("b")

    #expect(handler.configuration.selectedToolKind == .select)
    #expect(handler.effectiveTool.kind == .select)
    #expect(handler.overrides.isEmpty)
  }

  @Test func holdBindingOnlyAppliesWhileKeyIsHeld() {
    let configuration = ToolConfiguration(
      tools: [SelectTool(), BrushTool()],
      bindings: [
        .init(.keyOnly("b"), target: .brush, mode: .hold)
      ],
      selectedToolKind: .select,
    )
    let handler = ToolHandler()
    handler.configuration = configuration

    handler.handleKeyDown("b")
    #expect(handler.effectiveTool.kind == .brush)
    #expect(handler.isSpringLoaded)

    handler.handleKeyUp("b")

    #expect(handler.configuration.selectedToolKind == .select)
    #expect(handler.effectiveTool.kind == .select)
    #expect(handler.overrides.isEmpty)
  }

  @Test func repeatedKeyDownDoesNotStackOverrides() {
    let configuration = ToolConfiguration(
      tools: [SelectTool(), BrushTool()],
      bindings: [
        .init(.keyOnly("b"), target: .brush, mode: .hold)
      ],
      selectedToolKind: .select,
    )
    let handler = ToolHandler()
    handler.configuration = configuration

    handler.handleKeyDown("b")
    handler.handleKeyDown("b")

    #expect(handler.overrides.count == 1)
    #expect(handler.effectiveTool.kind == .brush)
  }
}

private struct BrushTool: CanvasTool {
  let kind: CanvasToolKind = .brush
  let name: String = "Brush"
  let icon: String = "paintbrush"

  var dragBehaviour: PointerDragBehaviour { .continuous }
  var inputCapabilities: [ToolCapability] {
    [ToolCapability(interaction: .drag, intent: .adjustBrushSize)]
  }

  func resolvePointerStyle(context: InteractionContext) -> PointerStyleCompatible { .rectSelection }

  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    .handled(.none)
  }
}

private struct CustomZoomTool: CanvasTool {
  let kind: CanvasToolKind = .zoom
  let name: String
  let icon: String = "magnifyingglass.circle"

  var dragBehaviour: PointerDragBehaviour { .continuous(axes: .vertical) }
  var inputCapabilities: [ToolCapability] {
    [ToolCapability(interaction: .drag, intent: .zoom)]
  }

  func resolvePointerStyle(context: InteractionContext) -> PointerStyleCompatible { .zoomIn }

  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    .handled(.none)
  }
}
