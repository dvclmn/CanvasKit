//
//  CanvasTransformState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 1/3/2026.
//

import CoreTools
import GestureKit
import SwiftUI

/// Value-semantic snapshot of canvas transform interactions.
public struct CanvasTransformState: Sendable {
  public var pan: PanState
  public var zoom: ZoomState
  public var rotation: RotateState
  public var latchedZoomFocusGlobal: CGPoint?

  public init(
    pan: PanState = .initial,
    zoom: ZoomState = .initial,
    rotation: RotateState = .initial,
    latchedZoomFocusGlobal: CGPoint? = nil
  ) {
    self.pan = pan
    self.zoom = zoom
    self.rotation = rotation
    self.latchedZoomFocusGlobal = latchedZoomFocusGlobal
  }
}

extension CanvasTransformState {
  public static var initial: Self { .init() }

  public var isPerformingGesture: Bool {
    pan.isActive || zoom.isActive || rotation.isActive
  }
}
