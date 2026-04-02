//
//  CanvasInputResolution.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/4/2026.
//

struct CanvasInputResolution {
  let globalAdjustment: CanvasAdjustment
  let toolResolution: ToolResolution

  var pointerAdjustment: CanvasAdjustment {
    toolResolution.adjustment
  }

  var toolAction: ToolAction {
    toolResolution.action
  }
}
