//
//  ArtworkSubViews.swift
//  CanvasKit
//
//  Created by Dave Coleman on 23/4/2026.
//

import SwiftUI

/// Uses SwiftUI subview APIs for granular control over canvas clipping.
///
/// This drives modifier `canvasClipped(_:)`, giving the user control
/// over whether or not a View nested within `CanvasView` should
/// be clipped to the canvas size.
struct CanvasArtworkDecomposed<Content: View>: View {

  let rounding: Double
  @ViewBuilder var content: () -> Content

  var body: some View {

    if #available(macOS 15.0, iOS 18.0, *) {
      Group(subviews: content()) { subviews in
        SubViews(subviews)
      }
    } else {
      ZStack(content: content)
    }
  }
}

extension CanvasArtworkDecomposed {
  @available(macOS 15.0, iOS 18.0, *)
  @ViewBuilder
  private func SubViews(_ subviews: SubviewsCollection) -> some View {
    ZStack {
      ForEach(subviews: subviews) { subview in
        if subview.containerValues.allowsCanvasClipping {
          subview.clipShape(.rect(cornerRadius: rounding))
        } else {
          subview
        }
      }
    }
  }
}
