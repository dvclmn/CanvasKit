//
//  CanvasGeometry.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/1/2026.
//

import Foundation

public struct CanvasGeometry: Sendable, Equatable {
  public var viewportSize: CGSize
  public var canvasSize: CGSize
  
  public init?(
    viewportSize: CGSize?,
    canvasSize: CGSize?,
  ) {
    guard let viewportSize, let canvasSize else {
      return nil
    }
    self.viewportSize = viewportSize
    self.canvasSize = canvasSize
  }
}
