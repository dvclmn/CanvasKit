//
//  CellSelectionCanvas.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 25/2/2026.
//

import BasePrimitives
import CanvasKit
import GraphicsKit
import SwiftUI

extension GridCanvas {
  struct CellSelectionCanvas: View {
    @Environment(CellSelectionHandler.self) private var store
    @Environment(\.unitSize) private var unitSize
    @Environment(\.cornerRounding) private var cornerRounding
    @Environment(\.gridDimensions) private var gridDimensions
    @Environment(\.canvasBackground) private var canvasBackground
    @Environment(\.gridGeometry) private var gridGeometry
    @Environment(\.isShowingCellNumbers) private var isShowingCellNumbers
    @Environment(\.pointerGridPosition) private var pointerGridPosition
    @Environment(\.isCellSelectionEnabled) private var isCellSelectionEnabled

    private let rounding: CGFloat = 4

    var body: some View {

      Canvas(
        opaque: true,
        rendersAsynchronously: true
      ) { context, size in

        context.fillCanvas(with: canvasBackground, in: size)

        /// Grid Lines
        context.drawGrid(
          domain: .canvas,
          in: size,
          sizeMode: .fillContainer,
          pinMode: .canvas,
          drawsBorder: false
        )

        /// Selected Cells
        drawSelection(context)

        /// Hovered Cell rect
        drawHoverCell(context)

      }  // END canvas
    }
  }
}

extension GridCanvas.CellSelectionCanvas {

  private func drawHoverCell(_ context: GraphicsContext) {
    guard isCellSelectionEnabled else { return }
    guard let rect = selectionRect,
      let gridDimensions,
      let hoverPos = pointerGridPosition
    else { return }

    let radii = rectRadii(
      dimensions: gridDimensions,
      position: hoverPos
    )

    let path = Path(roundedRect: rect, cornerRadii: radii)

    context.fillAndStroke(
      path,
      fillColour: .cyan.opacity(0.25),
      strokeColour: .blue.opacity(0.8),
      strokeThickness: 1
    )
  }

  private var selectionRect: CGRect? {
    guard let position = pointerGridPosition else { return nil }
    guard let cellSize = gridGeometry?.projection.unitSize else { return nil }

    let gridRect = GridRect(origin: position, size: 1)
    return gridRect.toScreenRect(using: cellSize)
  }

  var canvasOffset: CGSize? {
    guard let unitSize else { return nil }
    let result = isShowingCellNumbers ? -unitSize : nil
    //    print("Canvas Offset: \(result?.displayString(.concise), default: "nil")")
    return result
  }

  private func rectRadii(
    dimensions: GridDimensions,
    position: GridPosition,
  ) -> RectangleCornerRadii {
    let rounding: CGFloat = cornerRounding ?? Styles.sizeTiny
    //    guard let gridDimensions else { return nil }
    //    guard let position = store.pointerGridPosition else { return nil }

    /// Determine if the current position is at any of the four grid corners.
    let isTop = position.row == 0
    let isLeft = position.column == 0
    let isBottom = position.isLastRow(in: dimensions)
    let isRight = position.isLastColumn(in: dimensions)

    /// Round only the corners that coincide with the grid's outer corners.
    let topLeading: CGFloat = (isTop && isLeft) ? rounding : .zero
    let topTrailing: CGFloat = (isTop && isRight) ? rounding : .zero
    let bottomLeading: CGFloat = (isBottom && isLeft) ? rounding : .zero
    let bottomTrailing: CGFloat = (isBottom && isRight) ? rounding : .zero

    return RectangleCornerRadii(
      topLeading: topLeading,
      bottomLeading: bottomLeading,
      bottomTrailing: bottomTrailing,
      topTrailing: topTrailing
    )
  }
}

// MARK: - Selection Rendering

extension GridCanvas.CellSelectionCanvas {

  private func drawSelection(_ context: GraphicsContext) {
    guard isCellSelectionEnabled else { return }
    guard !store.selected.isEmpty else { return }
    guard let cellSize = gridGeometry?.projection.unitSize ?? unitSize else { return }

    /// Fill selected cells
    drawSelectionFill(
      context,
      selected: store.selected,
      cellSize: cellSize,
      color: .cyan.opacity(0.2)
    )

    /// Stroke outer outline with emphasis
    let outline = GridSelectionOutline.segments(from: store.selected)

    drawSelectionOutline(
      context,
      segments: outline,
      cellSize: cellSize,
      color: .blue.opacity(0.9),
      lineWidth: 2
    )
  }

  private func drawSelectionFill(
    _ context: GraphicsContext,
    selected: Set<GridPosition>,
    cellSize: CGSize,
    color: Color
  ) {
    for position in selected {
      let gridRect = GridRect(origin: position, size: 1)
      let rect = CGRect(fromGridRect: gridRect, using: cellSize)
      //      let rect = CGRect(
      //        x: CGFloat(position.column) * cellSize.width,
      //        y: CGFloat(position.row) * cellSize.height,
      //        width: cellSize.width,
      //        height: cellSize.height
      //      )
      context.fill(Path(rect), with: .color(color))
    }
  }

  private func drawSelectionOutline(
    _ context: GraphicsContext,
    segments: Set<GridOutlineSegment>,
    cellSize: CGSize,
    color: Color,
    lineWidth: CGFloat
  ) {
    let style = StrokeStyle(lineWidth: lineWidth, lineCap: .square, lineJoin: .round)
    for e in segments {
      var p = Path()
      let p1 = GridScreenConversion.screenPoint(
        for: GridPosition(column: e.x1, row: e.y1),
        unitSize: cellSize
      )
      let p2 = GridScreenConversion.screenPoint(
        for: GridPosition(column: e.x2, row: e.y2),
        unitSize: cellSize
      )
      p.move(to: p1)
      p.addLine(to: p2)
      context.stroke(p, with: .color(color), style: style)
    }
  }
}
