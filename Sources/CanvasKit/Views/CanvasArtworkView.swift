//
//  CanvasSurfaceView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import CoreTools
import SwiftUI

struct CanvasArtwork<Content: View>: View {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.zoomClamped) private var zoomClamped
  @Environment(\.canvasBackground) private var canvasBackground

  @ViewBuilder var content: () -> Content

  var body: some View {
    canvasDecomposed
      .frame(
        width: store.geometry?.canvasSize.width,
        height: store.geometry?.canvasSize.height
      )
      .scaleEffect(zoomClamped)
//      .scaleEffect(store.zoomClamped)
      .offset(store.panGesture.pan)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .allowsHitTesting(false)
      .background(canvasBackground)
      .drawingGroup(opaque: true)

  }
}

extension CanvasArtwork {
  @ViewBuilder
  private var canvasDecomposed: some View {
    if #available(macOS 15.0, iOS 18.0, *) {
      Group(subviews: content()) { subviewCollection in
        ZStack {
          ForEach(subviews: subviewCollection) { subview in
            if subview.containerValues.allowsCanvasClipping {
              subview
                .clipShape(.rect(cornerRadius: cornerRounding))
            } else {
              subview
            }
          }
        }
        .overlay {
          RoundedRectangle(cornerRadius: cornerRounding)
            .fill(.clear)
            .stroke(.white.opacity(0.07), lineWidth: outlineThickness)
            .allowsHitTesting(false)
        }
      }
    } else {
      ZStack {
        content()
      }
      .modifier(CanvasOutlineModifier())
    }
  }

  private var cornerRounding: CGFloat {
    let base = Styles.sizeTiny
    return base.removingZoom(zoomLevel)
  }

  private var outlineThickness: CGFloat {
    let base = 1.0
    return base.removingZoom(zoomLevel, across: zoomRange)
  }
}
