//
//  CanvasCoordinateSpace.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 25/2/2026.
//

@_spi(Internals) import BasePrimitives
import InteractionKit
import SwiftUI

extension EnvironmentValues {

  /// `canvasAnchor` is useful for both Canvas and Grid domains.
  /// Describes the anchor point for layout in ``CanvasArtworkView``.
  /// Important for coordinate space calculations.
  @Entry var canvasAnchor: UnitPoint = .center
  @Entry public var canvasBackground: Color = Color(white: 0.04)
  @Entry public var activeTool: (any CanvasTool)?

  /// Named `artworkOutline` to indicate this is plumbing
  /// set up specifically for CanvasKit, to drive easy configuration
  /// of the artwork outline for users.
  @Entry var artworkOutline: AreaOutline = .init()

}
