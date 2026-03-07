//
//  CanvasTransformState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 1/3/2026.
//

import BasePrimitives
import GestureKit
import SwiftUI

extension CanvasState {

  /// Value-semantic snapshot of canvas transform interactions.
  public struct TransformState: Sendable, Equatable {
    public var panState: PanState
    public var zoomState: ZoomState
    public var rotationState: RotateState
    public var latchedZoomFocusGlobal: CGPoint?

    public init(
      pan: PanState = .initial,
      zoom: ZoomState = .initial,
      rotation: RotateState = .initial,
      latchedZoomFocusGlobal: CGPoint? = nil
    ) {
      self.panState = pan
      self.zoomState = zoom
      self.rotationState = rotation
      self.latchedZoomFocusGlobal = latchedZoomFocusGlobal
    }
  }

}
extension CanvasState.TransformState {
  public static var initial: Self { .init() }

  public var isPerformingGesture: Bool {
    panState.isActive || zoomState.isActive || rotationState.isActive
  }
}

