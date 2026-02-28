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
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.viewportRect) private var viewportRect

  //  @State private var hasZoomedToFit: Bool = false

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
      
      CanvasCoreView()
//      canvasSurface
        .environment(store)
        .task(id: viewportRect) { store.updateViewportRect(viewportRect) }
      
    } else {
      Text("No Viewport rect provided")
    }
  }
}

extension CanvasView {
//
//  private var canvasSurface: some View {
//   
//  }
//
//  private var canvasLayer: some View {
//    content
//
//  }
}
