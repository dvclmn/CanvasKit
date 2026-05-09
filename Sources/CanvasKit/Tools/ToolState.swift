//
//  ToolState.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/5/2026.
//

public protocol ToolState {
  
  // From `commitTool(_ kind:)`
  func setSelected(_ kind: CanvasToolKind)
}
