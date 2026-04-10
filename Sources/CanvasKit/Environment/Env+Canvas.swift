//
//  CanvasCoordinateSpace.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 25/2/2026.
//

import InteractionKit
import SwiftUI
@_spi(Internals) import BasePrimitives

extension EnvironmentValues {

  // MARK: - Geometry
  /// This is useful for both Canvas and Grid domains. Describes the anchor
  /// used for SwiftUI layout by the main Artwork View in a CanvasView.
  /// Important for coordinate space calculations.
  @Entry public var canvasAnchor: UnitPoint = .center
  @Entry public var canvasBackground: Color = Color(white: 0.04)
  @Entry public var activeTool: (any CanvasTool)?
  
  /// Named `artworkOutline` to indicate this is plumbing
  /// set up specifically for CanvasKit, to drive easy configuration
  /// of the artwork outline for users.
  @Entry var artworkOutline: AreaOutline = .init()
  
  @Entry package var canvasSize: Size<CanvasSpace> = .zero
  @Entry package var transform: TransformState = .identity
  
}
