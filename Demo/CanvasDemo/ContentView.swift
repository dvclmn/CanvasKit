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
  @State private var transform: TransformState
  private let toolConfiguration: ToolConfiguration
  @State private var clipping: CanvasClipping

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

      SunflowerImage()
      //                CanvasContentView()
    }
    .canvasZoomRange(0.1...20)

    .toolPalette(
      isEnabled: true,
      alignment: .topLeading,
      width: nil,
      horizontalPadding: nil,
    )

    .overlay(alignment: .bottomTrailing) {
      SunflowerAttributionView()
    }

  }
}

extension ContentView {
  @ViewBuilder
  private func SunflowerImage() -> some View {
    Image(.sunflower)
      .resizable()
      .scaledToFill()
      .canvasClipping(clipping)
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
