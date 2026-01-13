//
//  Canvas+Environment.swift
//  BaseComponents
//
//  Created by Dave Coleman on 8/7/2025.
//

import GestureKit
import SwiftUI

extension EnvironmentValues {
  @Entry public var canvasContext: CanvasTransformContext? = nil
  @Entry public var canvasHandler: CanvasHandler = .init()
  
  
//  @Entry public var interaction: PointerPhase? = nil
//  @Entry public var isHoverEnabled: Bool = true
//  @Entry public var isDragEnabled: Bool = true
}
