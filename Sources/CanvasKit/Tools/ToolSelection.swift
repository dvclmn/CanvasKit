//
//  ToolSelection.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/5/2026.
//


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
