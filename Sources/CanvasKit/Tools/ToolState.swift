//
//  ToolState.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/5/2026.
//

// Was considering this as a way for a user to fashion whatever type
// they want, with simple controls for tools. Only the neccessary bits exposed.
public protocol ToolState {
  
  // From `ToolHandler.setCommittedTool(kind:)`
  func setSelected(_ kind: CanvasToolID)
}
