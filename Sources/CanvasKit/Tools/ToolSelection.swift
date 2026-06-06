//
//  ToolSelection.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/5/2026.
//

/// Mutable user/session state.
public struct ToolSelection: Sendable, Equatable {
  public var committedToolID: CanvasToolID

  public init(kind committedToolID: CanvasToolID = .select) {
    self.committedToolID = committedToolID
  }
}

extension ToolSelection {
  public static var `default`: Self { .init() }
}
