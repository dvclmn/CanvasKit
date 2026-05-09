//
//  ToolRegistry.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/5/2026.
//

import Foundation

/// Mostly static project/app declaration.
public struct Tools: Sendable {
  public let tools: [any CanvasTool]
  public let bindings: [ToolBinding]
  public let springLoadDelay: TimeInterval
  
  public init(
    tools: [any CanvasTool] = .defaultTools,
    bindings: [ToolBinding] = ToolBinding.defaultBindings(),
    springLoadDelay: TimeInterval = 0.15,
  ) {
    self.tools = tools
    self.bindings = bindings
    self.springLoadDelay = springLoadDelay
  }
}

extension Tools {
  public static var `default`: Self { .init() }
}

/// Mutable user/session state.
public struct ToolSelection: Sendable, Equatable {
  public var committedToolKind: CanvasToolKind
  
  public init(committedToolKind: CanvasToolKind = .select) {
    self.committedToolKind = committedToolKind
  }
}

extension ToolSelection {
  public static var `default`: Self { .init() }
}
