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

  public init(id committedToolID: CanvasToolID) {
    self.committedToolID = committedToolID
  }

  /// Falls back to default tool ID `select` if no configuration default found
  public init(configuration: ToolConfiguration) {
    let id = configuration.defaultToolID ?? .select
    self.init(id: id)
  }
}

extension ToolSelection {
  
  /// The default tool selection is the Select Tool
  public static var `default`: Self { .init(id: .select) }
}
