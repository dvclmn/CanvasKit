//
//  CanvasToolConfigurationTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 25/2/2026.
//

//import Foundation
//import SwiftUI
//import Testing
//
//@testable import CanvasKit
//
//extension CanvasToolID {
//  static let brush = Self("brush")
//}
//
//struct ToolConfigurationTests {
//
//  @Test func defaultToolKindDefaultsToFirstRegisteredTool() {
//    let configuration = ToolConfiguration(
//      tools: [BrushTool(), SelectTool(), ZoomTool()],
//      bindings: [],
//    )
//    let handler = ToolHandler(configuration: configuration)
//
//    #expect(configuration.defaultToolKind == .brush)
//    #expect(handler.committedToolKind == .brush)
//    #expect(handler.committedToolKindOrDefault == .brush)
//  }
//
//  @Test func invalidInitialSelectionNormalisesToDefaultToolInHandler() {
//    let configuration = ToolConfiguration(
//      tools: [BrushTool(), SelectTool()],
//      bindings: [],
//    )
//    let handler = ToolHandler(
//      configuration: configuration,
//      selection: .init(committedToolKind: .zoom),
//    )
//
//    #expect(handler.committedToolKind == .brush)
//  }
//
//  @Test func duplicateToolKindsKeepFirstPositionButReplaceValue() {
//    let configuration = ToolConfiguration(
//      tools: [SelectTool(), CustomZoomTool(name: "Zoom A"), BrushTool(), CustomZoomTool(name: "Zoom B")],
//      bindings: [],
//    )
//
//    #expect(configuration.tools.map(\.kind) == [.select, .zoom, .brush])
//    #expect(configuration.registeredTool(for: .zoom)?.name == "Zoom B")
//  }
//
//  @Test func selectingMissingToolDoesNothing() {
//    let configuration = ToolConfiguration(
//      tools: [SelectTool(), BrushTool()],
//      bindings: [],
//    )
//    let handler = ToolHandler(
//      configuration: configuration,
//      selection: .init(committedToolKind: .brush),
//    )
//
//    handler.setCommittedTool(kind: .zoom)
//
//    #expect(handler.committedToolKind == .brush)
//  }
//
//  @Test func invalidAndDuplicateBindingsAreSurfacedSeparatelyFromActiveBindings() {
//    let configuration = ToolConfiguration(
//      tools: [SelectTool(), BrushTool()],
//      bindings: [
//        .init(.keyOnly("v"), target: .select, mode: .sticky),
//        .init(.keyOnly("v"), target: .brush, mode: .sticky),
//        .init(.keyOnly("z"), target: .zoom, mode: .sticky),
//      ],
//    )
//
//    #expect(configuration.activeBindings.map(\.target) == [.select, .brush])
//    #expect(configuration.invalidBindings.map(\.target) == [.zoom])
//    #expect(configuration.duplicateBindings.map(\.target) == [.brush])
//  }
//
//  @Test func setToolsNormalisesOrder() {
//    var configuration = ToolConfiguration(
//      tools: [SelectTool(), ZoomTool()],
//      bindings: [],
//    )
//
//    configuration.setTools([BrushTool(), CustomZoomTool(name: "Zoom B"), BrushTool()])
//
//    #expect(configuration.tools.map(\.kind) == [.brush, .zoom])
//    #expect(configuration.defaultToolKind == .brush)
//
//    configuration.setTools([BrushTool()])
//
//    #expect(configuration.tools.map(\.kind) == [.brush])
//    #expect(configuration.defaultToolKind == .brush)
//  }
//
//  @Test func handlerRepairsSelectionWhenConfigurationChanges() {
//    let configuration = ToolConfiguration(
//      tools: [SelectTool(), ZoomTool()],
//      bindings: [],
//    )
//    let handler = ToolHandler(
//      configuration: configuration,
//      selection: .init(committedToolKind: .zoom),
//    )
//
//    handler.configuration.setTools([BrushTool()])
//
//    #expect(handler.committedToolKind == .brush)
//    #expect(handler.effectiveTool.kind == .brush)
//  }
//
//  @Test func moveToolReordersExistingToolOnly() {
//    var configuration = ToolConfiguration(
//      tools: [SelectTool(), BrushTool(), ZoomTool()],
//      bindings: [],
//    )
//
//    configuration.moveTool(kind: .zoom, to: 0)
//    #expect(configuration.tools.map(\.kind) == [.zoom, .select, .brush])
//
//    configuration.moveTool(kind: .pan, to: 1)
//    #expect(configuration.tools.map(\.kind) == [.zoom, .select, .brush])
//  }
//}
//
//struct ToolHandlerTests {
//
//  @Test func handlerIgnoresBindingTargetsThatAreNotRegistered() {
//    let configuration = ToolConfiguration(
//      tools: [SelectTool()],
//      bindings: [
//        .init(.keyOnly("z"), target: .zoom, mode: .sticky)
//      ],
//    )
//    let handler = ToolHandler(configuration: configuration)
//
//    handler.handleKeyDown("z")
//
//    #expect(handler.effectiveToolKind == .select)
//    #expect(handler.overrides.isEmpty)
//  }
//
//  @Test func bindingPrecedencePrefersExactModifierMatchThenMostSpecificSubset() {
//    let configuration = ToolConfiguration(
//      tools: [SelectTool(), BrushTool(), ZoomTool()],
//      bindings: [
//        .init(KeyboardShortcut("b", modifiers: []), target: .select, mode: .sticky),
//        .init(KeyboardShortcut("b", modifiers: [.shift]), target: .brush, mode: .sticky),
//        .init(KeyboardShortcut("b", modifiers: [.shift, .command]), target: .zoom, mode: .sticky),
//      ],
//    )
//    let handler = ToolHandler(
//      configuration: configuration,
//      selection: .init(committedToolKind: .select),
//    )
//
//    handler.updateModifiers([.shift, .command])
//    handler.handleKeyDown("b")
//    #expect(handler.effectiveTool.kind == .zoom)
//    handler.handleKeyUp("b")
//    #expect(handler.committedToolKind == .zoom)
//
//    handler.setCommittedTool(kind: .select)
//    handler.updateModifiers([.shift])
//    handler.handleKeyDown("b")
//    #expect(handler.effectiveTool.kind == .brush)
//    handler.handleKeyUp("b")
//    #expect(handler.committedToolKind == .brush)
//  }
//
//  @Test func stickyShortPressCommitsSelection() {
//    let configuration = ToolConfiguration(
//      tools: [SelectTool(), BrushTool()],
//      bindings: [
//        .init(.keyOnly("b"), target: .brush, mode: .sticky)
//      ],
//      springLoadDelay: 0.2,
//    )
//    let handler = ToolHandler(
//      configuration: configuration,
//      selection: .init(committedToolKind: .select),
//    )
//
//    handler.handleKeyDown("b")
//    #expect(handler.effectiveTool.kind == .brush)
//    #expect(handler.hasArmedSpringLoad == false)
//    #expect(handler.pendingSpringLoadArmingDelay != nil)
//
//    handler.handleKeyUp("b")
//
//    #expect(handler.committedToolKind == .brush)
//    #expect(handler.overrides.isEmpty)
//  }
//
//  @Test func stickyLongHoldSpringLoadsThenReverts() {
//    let configuration = ToolConfiguration(
//      tools: [SelectTool(), BrushTool()],
//      bindings: [
//        .init(.keyOnly("b"), target: .brush, mode: .sticky)
//      ],
//      springLoadDelay: 0.01,
//    )
//    let handler = ToolHandler(
//      configuration: configuration,
//      selection: .init(committedToolKind: .select),
//    )
//
//    handler.handleKeyDown("b")
//    Thread.sleep(forTimeInterval: 0.02)
//    handler.armPendingSpringLoads()
//
//    #expect(handler.armedSpringLoadedTool?.kind == .brush)
//    #expect(handler.hasArmedSpringLoad)
//    #expect(handler.pendingSpringLoadArmingDelay == nil)
//
//    handler.handleKeyUp("b")
//
//    #expect(handler.committedToolKind == .select)
//    #expect(handler.effectiveTool.kind == .select)
//    #expect(handler.overrides.isEmpty)
//  }
//
//  @Test func holdBindingOnlyAppliesWhileKeyIsHeld() {
//    let configuration = ToolConfiguration(
//      tools: [SelectTool(), BrushTool()],
//      bindings: [
//        .init(.keyOnly("b"), target: .brush, mode: .hold)
//      ],
//    )
//    let handler = ToolHandler(
//      configuration: configuration,
//      selection: .init(committedToolKind: .select),
//    )
//
//    handler.handleKeyDown("b")
//    #expect(handler.effectiveTool.kind == .brush)
//    #expect(handler.hasArmedSpringLoad)
//    #expect(handler.pendingSpringLoadArmingDelay == nil)
//
//    handler.handleKeyUp("b")
//
//    #expect(handler.committedToolKind == .select)
//    #expect(handler.effectiveTool.kind == .select)
//    #expect(handler.overrides.isEmpty)
//  }
//
//  @Test func repeatedKeyDownDoesNotStackOverrides() {
//    let configuration = ToolConfiguration(
//      tools: [SelectTool(), BrushTool()],
//      bindings: [
//        .init(.keyOnly("b"), target: .brush, mode: .hold)
//      ],
//    )
//    let handler = ToolHandler(
//      configuration: configuration,
//      selection: .init(committedToolKind: .select),
//    )
//
//    handler.handleKeyDown("b")
//    handler.handleKeyDown("b")
//
//    #expect(handler.overrides.count == 1)
//    #expect(handler.effectiveTool.kind == .brush)
//  }
//}
//
//private struct BrushTool: CanvasTool {
//  let kind: CanvasToolID = .brush
//  let name: String = "Brush"
//  let icon: String = "paintbrush"
//
//  var dragConfiguration: PointerDragConfiguration { .continuous }
//  var inputCapabilities: [ToolCapability] {
//    [ToolCapability(interaction: .drag, intent: .adjustBrushSize)]
//  }
//
//  func resolvePointerStyle(context: InteractionContext) -> PointerStyleCompatible { .rectSelection }
//
//  func resolveInteraction(
//    context: InteractionContext,
//    currentTransform: TransformState,
//  ) -> ToolResolution {
//    .handled(.none)
//  }
//}
//
//private struct CustomZoomTool: CanvasTool {
//  let kind: CanvasToolID = .zoom
//  let name: String
//  let icon: String = "magnifyingglass.circle"
//
//  var dragConfiguration: PointerDragConfiguration {
//    .init(behaviour: .continuous(axes: .vertical))
//  }
//  var inputCapabilities: [ToolCapability] {
//    [ToolCapability(interaction: .drag, intent: .zoom)]
//  }
//
//  func resolvePointerStyle(context: InteractionContext) -> PointerStyleCompatible { .zoomIn }
//
//  func resolveInteraction(
//    context: InteractionContext,
//    currentTransform: TransformState,
//  ) -> ToolResolution {
//    .handled(.none)
//  }
//}
