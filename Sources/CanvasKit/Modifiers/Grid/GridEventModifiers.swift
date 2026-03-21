//
//  GridEventModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 21/3/2026.
//

import BasePrimitives
import SwiftUI

// MARK: - Grid Tap

/// Observes pointer taps and delivers the tapped grid cell position.
///
/// This is the grid-layer analogue to `OnCanvasTapModifier`. It converts
/// continuous canvas-space coordinates into a discrete `GridPosition`
/// using the grid geometry from the environment.
struct OnGridTapModifier: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.gridGeometry) private var gridGeometry

  let action: (GridPosition) -> Void

  func body(content: Content) -> some View {
    content
      .onCanvasTap(in: CanvasSpace.self) { canvasPoint in
        guard let gridGeometry,
          let position = gridGeometry.projection.gridPositionIfValid(from: canvasPoint),
          gridGeometry.dimensions.contains(position: position)
        else { return }
        action(position)
      }
  }
}

// MARK: - Grid Drag

/// Observes pointer drags and delivers the selected grid cell range.
///
/// Converts the continuous drag rect into the top-left and bottom-right
/// grid positions that the rect spans.
struct OnGridDragModifier: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.gridGeometry) private var gridGeometry

  let action: (GridPosition, GridPosition) -> Void

  func body(content: Content) -> some View {
    content
      .onCanvasDrag(in: CanvasSpace.self) { canvasRect in
        guard let gridGeometry else { return }

        let projection = gridGeometry.projection
        let endPoint = Point<CanvasSpace>(x: canvasRect.maxX, y: canvasRect.maxY)

        guard
          let origin = projection.gridPositionIfValid(from: canvasRect.origin),
          let end = projection.gridPositionIfValid(from: endPoint)
        else { return }

        action(origin, end)
      }
  }
}

// MARK: - View extensions

extension View {

  /// React to pointer taps on grid cells.
  ///
  /// The grid-layer equivalent of `onCanvasTap`. Delivers a discrete
  /// `GridPosition` (column, row) rather than continuous coordinates.
  ///
  /// Requires `gridGeometry` to be available in the environment
  /// (provided automatically within a `GridCanvasView`).
  ///
  /// ```swift
  /// GridCanvasView {
  ///   MyArtwork()
  /// }
  /// .onGridTap { position in
  ///   selectCell(at: position)
  /// }
  /// ```
  public func onGridTap(
    perform action: @escaping (GridPosition) -> Void
  ) -> some View {
    self.modifier(OnGridTapModifier(action: action))
  }

  /// React to pointer drags across grid cells.
  ///
  /// Delivers the top-left and bottom-right `GridPosition` of the
  /// rectangular selection. Fires every frame the drag is active.
  ///
  /// ```swift
  /// GridCanvasView {
  ///   MyArtwork()
  /// }
  /// .onGridDrag { origin, end in
  ///   updateSelection(from: origin, to: end)
  /// }
  /// ```
  public func onGridDrag(
    perform action: @escaping (_ origin: GridPosition, _ end: GridPosition) -> Void
  ) -> some View {
    self.modifier(OnGridDragModifier(action: action))
  }
}
