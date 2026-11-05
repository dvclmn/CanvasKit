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
/// Modifier `canvasFrame()` is placed before
/// `clipShape(_:style:)`, so that clipping matches canvas size correctly.
struct ArtworkDecomposed<Content: View>: View {
  let rounding: Double
  let explicitCanvasSize: Size<CanvasSpace>?
  @ViewBuilder var content: () -> Content

  var body: some View {

    if #available(macOS 15.0, iOS 18.0, *) {
      Group(subviews: content()) { subviews in
        SubViews(subviews)
      }

    } else {
      ZStack(content: content)
        .canvasFrame(explicitCanvasSize)
    }
  }
}

extension ArtworkDecomposed {
  @available(macOS 15.0, iOS 18.0, *)
  @ViewBuilder
  private func SubViews(_ subviews: SubviewsCollection) -> some View {
    ZStack {
      // These subviews are already resolved by Group. Resolving them again
      // introduces another container boundary and loses their clipping values.
      ForEach(subviews) { subview in
        switch subview.containerValues.canvasClipping.resolved {
          case .clipped:
            subview
              .canvasFrame(explicitCanvasSize)
              .clipShape(.rect(cornerRadius: rounding))

          case .dimmed:
            subview
              .canvasFrame(explicitCanvasSize)
              //                            .border(Color.indigo.opacity(0.3))
              //              .overlay {
              .mask {
                CanvasDimmingMask(
                  cornerRadius: rounding,
                  dimmingAmount: subview.containerValues.canvasClipping.normalisedDimmingAmount,
                )
              }

          case .none:
            subview
              .canvasFrame(explicitCanvasSize)
        }
      }
    }
  }
}

// MARK: -

private struct CanvasSizeFrameModifier: ViewModifier {

  let size: Size<CanvasSpace>?
  //    let explicitCanvasSize: Size<CanvasSpace>?
  //  @Environment(\.explicitCanvasSize) private var explicitCanvasSize

  func body(content: Content) -> some View {
    content
      .frame(
        width: size?.width,
        height: size?.height,
      )
    //      .border(Color.mint.opacity(0.3))
    //      .debugText {
    //        Labeled("Explicit Canvas Size", value: explicitCanvasSize)
    //      }

  }
}
extension View {
  fileprivate func canvasFrame(_ size: Size<CanvasSpace>?) -> some View {
    self.modifier(CanvasSizeFrameModifier(size: size))
  }
}

#if DEBUG
@available(macOS 15.0, iOS 18.0, *)
#Preview("Artwork clipping and overflow") {
  @Previewable @State var clipping: CanvasClipping = .dimmed(0.5)

  VStack(spacing: 16) {
    CanvasClippingControls($clipping)
      .padding(.horizontal)

    CanvasView(size: CGSize(width: 200, height: 140)) {
      // An unmodified layer keeps the default clipping policy.
      Color.gray.opacity(0.2)

      // Ordinary SwiftUI content deliberately overflows the artwork bounds,
      // independently of any client's Canvas or bitmap rendering behaviour.
      Color.clear
        .overlay {
          Rectangle()
            .fill(.orange)
            .frame(width: 300, height: 60)
            .rotationEffect(.degrees(-25))
        }
        .canvasClipping(clipping)
    }
    .frame(width: 380, height: 280)
  }
  .padding(.vertical)
}
#endif
