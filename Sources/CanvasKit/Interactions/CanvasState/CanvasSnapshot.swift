//
//  CanvasSnapshot.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import SwiftUI
import InteractionPrimitives
import GeometryPrimitives

/// Computed from `Canvas​Interaction​State` + `Transform​State` + geometry.
/// Holds only already-converted, consumer-ready values
public struct CanvasSnapshot: Sendable {
  public let pointerLocation: Point<CanvasSpace>?
  public let isPointerInsideCanvas: Bool
  public let zoom: CGFloat
  public let pan: CGSize
  public let rotation: Angle
}
