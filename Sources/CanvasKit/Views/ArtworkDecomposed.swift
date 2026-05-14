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
  @Environment(\.canvasBackground) private var canvasBackground

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

private struct CanvasOutsideDimmer: View {
  let cornerRadius: Double
  let dimmingAmount: Double
  let colour: Color

  private let outsideExtent: CGFloat = 100_000

  var body: some View {
    GeometryReader { proxy in
      OutsideCanvasShape(
        size: proxy.size,
        cornerRadius: cornerRadius,
        outsideExtent: outsideExtent,
      )
      .fill(colour.opacity(dimmingAmount), style: FillStyle(eoFill: true))
    }
    .allowsHitTesting(false)
  }
}

private struct OutsideCanvasShape: Shape {
  let size: CGSize
  let cornerRadius: Double
  let outsideExtent: CGFloat

  func path(in rect: CGRect) -> Path {
    let canvasRect = CGRect(origin: .zero, size: size)
    let outsideRect = canvasRect.insetBy(dx: -outsideExtent, dy: -outsideExtent)

    return Path { path in
      path.addRect(outsideRect)
      path.addRoundedRect(
        in: canvasRect,
        cornerSize: CGSize(width: cornerRadius, height: cornerRadius),
      )
    }
  }
}
