//
//  ArtworkSubViews.swift
//  CanvasKit
//
//  Created by Dave Coleman on 23/4/2026.
//

import SwiftUI

/// Uses SwiftUI subview APIs for granular control over canvas clipping.
///
/// This drives modifier `canvasClipping(_:)`, giving the user control
/// over how a View nested within `CanvasView` should be displayed outside
/// the canvas size.
///
/// Modifier `canvasSizeFrame()` is placed before
/// `clipShape(_:style:)`, so that clipping matches canvas size correctly.
struct ArtworkDecomposed<Content: View>: View {
//  @Environment(\.canvasBackground) private var canvasBackground

  let rounding: Double
  @ViewBuilder var content: () -> Content

  var body: some View {

    if #available(macOS 15.0, iOS 18.0, *) {
      Group(subviews: content()) { subviews in
        SubViews(subviews)
      }
      
    } else {
      ZStack(content: content)
        .canvasSizeFrame()
    }
  }
}

extension ArtworkDecomposed {
  @available(macOS 15.0, iOS 18.0, *)
  @ViewBuilder
  private func SubViews(_ subviews: SubviewsCollection) -> some View {
    ZStack {
      ForEach(subviews: subviews) { subview in
        switch subview.containerValues.canvasClipping.resolved {
          case .clipped:
            subview
              .canvasSizeFrame()
              .clipShape(.rect(cornerRadius: rounding))

          case .dimmed:
            subview
              .canvasSizeFrame()
              .overlay {
                CanvasOutsideDimmer(
                  cornerRadius: rounding,
                  dimmingAmount: subview.containerValues.canvasClipping.normalisedDimmingAmount,
                  colour: canvasBackground,
                )
              }

          case .none:
            subview
              .canvasSizeFrame()
        }
      }
    }
  }
}

