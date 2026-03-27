//
//  GridCanvasView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 3/3/2026.
//

import BasePrimitives
import SwiftUI
import BaseUI

//public typealias GridCanvasView<Grid: GridShaped, Content: View> = GridCanvas<Grid>.GridCanvasView<Content>

//extension GridCanvas {
public struct GridCanvasView<Content: View>: View {
  @Environment(\.viewportRect) private var viewportRect
  @Environment(\.gridDimensions) private var gridDimensions
  @Environment(\.canvasAnchor) private var canvasAnchor
  @Environment(\.unitSize) private var unitSize

  let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    if let gridCanvasSize {
      CanvasView(canvasSize: gridCanvasSize, content: content)
    } else {
      StateView("Missing Grid Dimensions", icon: .emoji("🧊"))
    }
  }
}

extension GridCanvasView {
  //extension GridCanvas.GridCanvasView {
  private var gridCanvasSize: Size<CanvasSpace>? {
    guard let unitSize, let gridDimensions else { return nil }

    let size = gridDimensions.toScreenSize(using: unitSize)

    /// Verify that `toScreenSize(using:)` matches manual computation within tolerance
    let expected = CGSize(
      width: CGFloat(gridDimensions.width) * unitSize.width,
      height: CGFloat(gridDimensions.height) * unitSize.height
    )

    /// allow minor floating point drift and rounding
    let epsilon: CGFloat = 0.5
    let widthMatches = abs(size.width - expected.width) <= epsilon
    let heightMatches = abs(size.height - expected.height) <= epsilon

    let isMatching = widthMatches && heightMatches
    let alertMsg = isMatching ? "✔ Matching" : "⚠️ Mismatch"

    let mismatchMessage =
      """
      GridDimensions screen size conversion 
      \(alertMsg) 
      Expected: \(expected), 
      got: \(size). 

      gridDimensions: \(gridDimensions)
      unitSize: \(unitSize)
      epsilon: \(epsilon)


      """

    if !isMatching { print("\(mismatchMessage)") }

    assert(widthMatches && heightMatches, mismatchMessage)

    return Size<CanvasSpace>(fromCGSize: size)
  }
}
