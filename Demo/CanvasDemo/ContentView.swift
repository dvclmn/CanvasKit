//
//  ContentView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 9/1/2026.
//

import CanvasKit
import CoreUtilities
import SwiftUI

enum Constants {
  static let canvasSize: CGSize = CGSize(width: 380, height: 300)
}

struct ContentView: View {
  @State private var transform: TransformState
  @State private var toolConfiguration: ToolConfiguration
  @State private var clipping: CanvasClipping

  init(
    transform: TransformState = .init(),
    toolConfiguration: ToolConfiguration = .default,
    clipping: CanvasClipping = .clipped,
  ) {
    self._transform = State(initialValue: transform)
    self._toolConfiguration = State(initialValue: toolConfiguration)
    self._clipping = State(initialValue: clipping)
  }

  var body: some View {

    CanvasView(
//      size: Constants.canvasSize,
      transform: $transform,
      toolConfiguration: $toolConfiguration,
    ) {
      Image(.sunflower)
        .resizable()
        .scaledToFill()
        .canvasClipping(clipping)
      //      CanvasContentView()
    }
    .zoomRange(0.1...20)
    .toolPicker()

    //    .overlay(alignment: .topTrailing) {
    //      CanvasClippingControl($clipping)
    //        .frame(width: 240)
    //        .padding(10)
    //        .background(.regularMaterial)
    //        .clipShape(.rect(cornerRadius: 8))
    //        .padding()
    //    }

    .overlay(alignment: .bottomTrailing) {

      Text(
        "Photo by [Linus Belanger](https://unsplash.com/@linusbelanger?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/photos/a-single-sunflower-blooms-against-a-bright-blue-sky-ysB8453OSbI?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)"
      )
      .tint(.secondary.opacity(0.85))
      .font(.callout)
      .foregroundStyle(.tertiary)
      .padding(.horizontal, 6)
      .padding(.vertical, 3)
      //      .background(.gray.opacity(0.15))
      .background(.regularMaterial)
      .clipShape(.rect(cornerRadius: 5))
      .padding()
    }

    .debugTextOverlay(isEnabled: false)
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
