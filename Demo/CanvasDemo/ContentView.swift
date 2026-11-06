//
//  ContentView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 9/1/2026.
//

import CanvasKit
import SwiftUI

enum Constants {
  static let canvasSize: CGSize = CGSize(width: 380, height: 300)
}

struct ContentView: View {
  @State private var store: AppHandler = .init()
  @State private var transform: TransformState
  @State private var clipping: CanvasClipping
  private let toolConfiguration: ToolConfiguration

  init(
    transform: TransformState = .init(),
    toolConfiguration: ToolConfiguration = .default,
    clipping: CanvasClipping = .clipped,
  ) {
    self._transform = State(initialValue: transform)
    self.toolConfiguration = toolConfiguration
    self._clipping = State(initialValue: clipping)
  }

  var body: some View {

    CanvasView(
      size: Constants.canvasSize,
      transform: $transform,
      toolConfiguration: toolConfiguration,
    ) {
      switch store.sampleContent {
        case .image(let sampleImg): SampleImageView(sampleImage: sampleImg)
        case .vectorShapes: VectorShapes()
        case .drawing: Text("Not yet")
      }

    } viewportOverlay: {

      switch store.sampleContent {
        case .image(let img): ImageAttributionView(image: img)
        default: EmptyView()
      }
    }
    .canvasZoomRange(0.1...20)

    .toolPalette(
      isEnabled: true,
      alignment: .topLeading,
      width: nil,
      horizontalPadding: nil,
    )

  }
}

#if DEBUG
#Preview {
  @Previewable @State var transform = TransformState(
    translation: .zero,
    scale: 2,
  )
  @Previewable @State var toolConfiguration = ToolConfiguration()

  ContentView(
    transform: transform,
    toolConfiguration: toolConfiguration,
  )

  .frame(minWidth: 400, minHeight: 500)

}
#endif
