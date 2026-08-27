//
//  ToolSelection.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/5/2026.
//

/// Parent-ownable committed tool state.
///
/// This value represents the durable user choice only. CanvasKit keeps
/// key-held and spring-loaded effective-tool overrides in its internal runtime
/// handler and never writes those transient ids into this selection.
public struct ToolSelection: Sendable, Equatable, Hashable {
  public var committedToolID: CanvasToolID

  public init(id committedToolID: CanvasToolID = .select) {
    self.committedToolID = committedToolID
  }
}

extension ToolSelection {
  public static var `default`: Self { .init() }
}
