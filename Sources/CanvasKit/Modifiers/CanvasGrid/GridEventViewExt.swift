//
//  GridEventModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 21/3/2026.
//

import BasePrimitives
import SwiftUI

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
    perform action: @escaping (GridDragEvent) -> Void
//    perform action: @escaping (_ origin: GridPosition, _ end: GridPosition) -> Void
  ) -> some View {
    self.modifier(OnGridDragModifier(action: action))
  }
}
