//
//  GridCanvasView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 3/3/2026.
//

import BasePrimitives
import GestureKit
import SwiftUI

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
    CanvasView(gridCanvasSize: gridCanvasSize, content: content)
  }
}

/// A specialised CanvasView init for Grid usage
extension CanvasView {
  fileprivate init(
    gridCanvasSize: Size<CanvasSpace>?,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = gridCanvasSize
    self.content = content
  }
}

extension GridCanvasView {
  private var gridCanvasSize: Size<CanvasSpace>? {
    guard let unitSize, let gridDimensions,
      let size = gridDimensions.toScreenSize(using: unitSize)
    else { return nil }

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
