//
//  CanvasEnvironment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//

private import CoreTools
import SwiftUI

extension EnvironmentValues {
  /// A concrete canvas size, if passed by the caller. If value is nil, canvas size
  /// will be inferred via `CanvasHandler/resolvedCanvasSize(for:)`.
  @Entry var explicitCanvasSize: Size<CanvasSpace>?

  @Entry var isShowingToolPalette: Bool = false

  /// Anchor point used to lay out artwork within the viewport.
  @Entry var canvasAnchor: UnitPoint = .center

}

// MARK: - Canvas Events
extension EnvironmentValues {

  /// The interaction kinds currently active in the nearest ``CanvasView``.
  ///
  /// The value is ``CanvasInteractionActivity/none`` outside a canvas and after
  /// all interactions have ended or been cancelled.
  @Entry public var canvasInteractionActivity: CanvasInteractionActivity = .none

  /// Mapped pointer observations used internally by Canvas event modifiers.
  @Entry var pointerTap: PointerTapSnapshot<CanvasSpace>?
  @Entry var pointerHover: Point<CanvasSpace>?
  @Entry var canvasDragEvent: CanvasDragEvent?
}

extension EnvironmentValues {

  @Entry public var panOffset: CGSize = .zero
  @Entry public var rotation: Angle = .zero

  /// Important: This zoom level is not clamped.
  /// For clamped zoom use ``zoomClamped``, which clamps by ``zoomRange``
  @Entry public var zoomLevel: Double = 1.0

  @Entry @_spi(Internal) public var zoomRange: ClosedRange<Double> = 0.2...10
  @Entry @_spi(Internal) public var zoomSensitivity: Double = 0.5

  /// Returns `1.0` if `zoomLevel` is less than zero or NaN/infinite
  public var zoomClamped: Double {
    guard zoomLevel.isFiniteAndPositive else { return 1.0 }
    return zoomLevel.clamped(to: zoomRange)
  }

}
