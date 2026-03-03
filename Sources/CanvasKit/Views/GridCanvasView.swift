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

    CanvasCoreView(canvasGeometry: canvasGeometry, content: content)
      .environment(\.canvasSize, gridCanvasSize)
    //    if let gridCanvasSize {
    //      CanvasView(canvasSize: gridCanvasSize, content: content)
    //    } else {
    //      Text("No value found for `gridCanvasSize`")
    //    }
  }
}

extension GridCanvasView {

  private var canvasGeometry: CanvasGeometry? {
    guard let viewportRect, let gridCanvasSize else { return nil }
    return CanvasGeometry(
      viewportRect: viewportRect,
      canvasSize: gridCanvasSize,
      anchor: canvasAnchor
    )
  }

  private var gridCanvasSize: Size<CanvasSpace>? {

    guard let unitSize, let gridDimensions,
      let size = gridDimensions.toScreenSize(using: unitSize)
    else {
      print(
        """
        ---
        Couldn't return `gridCanvasSize`, no value found in Env for:
        `gridDimensions`: \(gridDimensions, default: "nil")
        gridDimensions -> CGSize: \( unitSize.map {gridDimensions?.toScreenSize(using: $0)}, default: "nil") 
        `unitSize`: \(unitSize, default: "nil")

        ---

        """
      )

      //      print("Unable to return `gridCanvasSize`, no `unitSize` and/or `gridDimensions` found in Env.")
      return nil
    }
    return Size<CanvasSpace>(fromCGSize: size)
  }
  //  private var canvasSize: Size<CanvasSpace>? {
  //    gridDimensions?.toScreenSize(using: <#T##CGSize#>)
  //  }
}
