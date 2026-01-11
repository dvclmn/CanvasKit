//
//  ContentView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 9/1/2026.
//

import CanvasKit
import SwiftUI
import ToolKit

struct ContentView: View {
  @State private var canvasHandler = CanvasHandler()
  let canvasSize: CGSize = CGSize(1200, 800)
  var body: some View {
    ZStack {
      CanvasView(handler: $canvasHandler) {
        ZStack {
          Circle().fill(.brown.tertiary)
            .padding()
          Text("Hello")
        }
      }
    }

    //    .infoBarView()
    .viewSize(mode: .debounce(0.3)) { size in
      canvasHandler.updateViewportSize(size)
    }
    .task(id: canvasSize) {
      canvasHandler.updateCanvasSize(canvasSize)
    }
    .background(.blue.quinary)
  }
}

#if DEBUG
#Preview {
  ContentView()
    .frame(minWidth: 660, minHeight: 500)
}
#endif
