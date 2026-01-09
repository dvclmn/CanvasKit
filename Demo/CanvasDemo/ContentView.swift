//
//  ContentView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 9/1/2026.
//

import SwiftUI
import CanvasKit

struct ContentView: View {
  @State private var canvasHandler = CanvasHandler()
//  @Binding var document: CanvasDemoDocument

  var body: some View {
    CanvasView(handler: $canvasHandler) {
      Text("Hello")
    }

    .background(.blue.quinary)
  }
}

#if DEBUG
#Preview {
  ContentView()
}
#endif
