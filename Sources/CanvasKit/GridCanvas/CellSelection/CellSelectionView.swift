//
//  CellSelection.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 25/2/2026.
//

import BasePrimitives
import LayoutKit
import SwiftUI

extension GridCanvas {
  public struct CellSelectionView<Content: View>: View {
    @Environment(CellSelectionHandler.self) private var store
    @Environment(\.unitSize) private var unitSize
    @Environment(\.gridDimensions) private var gridDimensions

    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
      self.content = content
    }
    public var body: some View {

      @Bindable var store = store

      GridCanvasView {
        CellSelectionCanvas()
          .allowsCanvasClipping(false)
          .onGridTap { store.handleTap([$0]) }
          .onGridDrag { handleDrag($0) }

        content()
      }

      .debugTextOverlay(alignment: .bottomLeading) {
        Labeled("Selection Mode", value: store.mode.name)
        Labeled("Selected Cells", value: store.selected.count)
      }

      .environment(\.shouldShowInfoBarItems, true)

      .syncModifiers(to: $store.modifiers)
      .task(id: unitSize) { store.updateCellSize(unitSize) }
    }
  }
}

extension GridCanvas.CellSelectionView {

  private func handleDrag(_ event: GridDragEvent) {
    guard let dimensions = gridDimensions else { return }
    store.handleDrag(event, dimensions: dimensions)
  }

}
