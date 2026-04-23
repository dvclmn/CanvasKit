//
//  CanvasToolConfigurationTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 25/2/2026.
//

import Testing
import InputPrimitives
@testable import CanvasKit

@Test func registeringAToolWithAnExistingKindReplacesIt() {
  var configuration = ToolConfiguration(
    tools: [SelectTool(), CustomZoomTool()],
    bindings: [
      .init(.keyOnly("v"), target: .select, mode: .sticky),
      .init(.keyOnly("z"), target: .zoom, mode: .sticky),
    ],
    selectedToolKind: .zoom
  )

  #expect(configuration.selectedToolKind == .zoom)
  #expect(configuration.tool(for: .zoom)?.name == "Zoom+")
  #expect(configuration.availableTools.map { $0.kind } == [.select, .zoom])

  configuration.register(DefaultZoomTool())
  #expect(configuration.tool(for: .zoom)?.name == "Zoom")

  configuration.removeTool(kind: .zoom)
  #expect(configuration.tool(for: .zoom) == nil)
  #expect(configuration.selectedToolKind == .select)
}

private struct CustomZoomTool: CanvasTool {
  let kind: CanvasToolKind = .zoom
  let name = "Zoom+"
  let icon = "magnifyingglass.circle"

  var dragBehaviour: PointerDragBehaviour { .continuous(axes: .vertical) }
  var inputCapabilities: [ToolCapability] { ToolCapability.zoom }

  func resolvePointerStyle(
    context: InteractionContext
  ) -> PointerStyleCompatible { .zoomIn }

  func resolvePointerInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    .none
  }
}

private struct DefaultZoomTool: CanvasTool {
  let kind: CanvasToolKind = .zoom
  let name = "Zoom"
  let icon = "magnifyingglass"

  var dragBehaviour: PointerDragBehaviour { .continuous(axes: .vertical) }
  var inputCapabilities: [ToolCapability] { ToolCapability.zoom }

  func resolvePointerStyle(
    context: InteractionContext
  ) -> PointerStyleCompatible { .zoomIn }

  func resolvePointerInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    .none
  }
}
