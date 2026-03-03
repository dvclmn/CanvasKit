//
//  GridCanvasView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 3/3/2026.
//

import CoreTools
import GestureKit
import SwiftUI

public struct GridCanvasView<Content: View>: View {
  @Environment(\.viewportRect) private var viewportRect
  @Environment(\.gridDimensions) private var gridDimensions
  @Environment(\.canvasAnchor) private var canvasAnchor
  @Environment(\.unitSize) private var unitSize

  let content: () -> Content

  public init(
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.content = content
  }

  public var body: some View {

    CanvasView(gridCanvasSize: gridCanvasSize, content: content)
    //    CanvasCoreView(canvasGeometry: canvasGeometry, content: content)
    //      .environment(\.canvasSize, gridCanvasSize)
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
    return Size<CanvasSpace>(fromCGSize: size)
  }

  //  private var canvasGeometry: CanvasGeometry? {
  //    guard let viewportRect, let gridCanvasSize else { return nil }
  //    return CanvasGeometry(
  //      viewportRect: viewportRect,
  //      canvasSize: gridCanvasSize,
  //      anchor: canvasAnchor
  //    )
  //  }
  //
  //  private var gridCanvasSize: Size<CanvasSpace>? {
  //
  //    guard let unitSize, let gridDimensions,
  //      let size = gridDimensions.toScreenSize(using: unitSize)
  //    else {
  //      print(
  //        """
  //        ---
  //        Couldn't return `gridCanvasSize`, no value found in Env for:
  //        `gridDimensions`: \(gridDimensions, default: "nil")
  //        gridDimensions -> CGSize: \( unitSize.map {gridDimensions?.toScreenSize(using: $0)}, default: "nil")
  //        `unitSize`: \(unitSize, default: "nil")
  //
  //        ---
  //
  //        """
  //      )
  //
  //      //      print("Unable to return `gridCanvasSize`, no `unitSize` and/or `gridDimensions` found in Env.")
  //      return nil
  //    }
  //    return Size<CanvasSpace>(fromCGSize: size)
  //  }
  //  private var canvasSize: Size<CanvasSpace>? {
  //    gridDimensions?.toScreenSize(using: <#T##CGSize#>)
  //  }
}
