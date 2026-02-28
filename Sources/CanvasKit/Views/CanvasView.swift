//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

//import BaseUI
import CoreTools
import GestureKit
import SwiftUI

public struct CanvasView<Content: View>: View {
  @Environment(\.isDebugMode) private var isDebugMode
  @Environment(\.modifierKeys) private var modifierKeys
  @Environment(\.viewportRect) private var viewportRect

  @State var store = CanvasHandler()

  let canvasSize: CGSize
  let showsInfoBar: Bool
  let content: Content

  public init(
    canvasSize: CGSize,
    showsInfoBar: Bool = true,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = canvasSize
    self.showsInfoBar = showsInfoBar
    self.content = content()
  }

  public var body: some View {
    
    if let viewportRect {
      CanvasCoreView { content }
        .environment(store)
        .environment(\.canvasSize, canvasSize)
        .task(id: viewportRect) { store.updateViewportRect(viewportRect) }
        .task(id: canvasSize) { store.updateCanvasSize(canvasSize) }

    } else {
      Text("No Viewport rect provided")
    }
  }
}
