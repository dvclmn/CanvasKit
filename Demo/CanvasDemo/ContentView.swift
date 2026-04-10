//
//  ContentView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 9/1/2026.
//

import CanvasKit
import SwiftUI

struct ContentView: View {
  let canvasSize: CGSize = CGSize(width: 380, height: 300)
  var body: some View {
    CanvasView(size: canvasSize) {
      Circle().fill(.brown.tertiary)
        .padding()
      Text("Hello")
    }
  }
}

#if DEBUG
#Preview {
  ContentView()
    .frame(minWidth: 400, minHeight: 500)
}
#endif
