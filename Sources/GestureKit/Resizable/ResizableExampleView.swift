//
//  ResizableExampleView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 21/2/2026.
//

import SwiftUI

struct ResizableExampleView: View {

  @State private var overlayHeight: CGFloat = 200

  private let resizeLengths: (min: Double, initial: Double, max: Double) = (70, 240, 400)

  var body: some View {

    HStack(spacing: 0) {
      VStack(spacing: 0) {
        Color.blue.opacity(0.15)

        Color.green.opacity(0.15)
          .frame(maxHeight: .infinity)
          .resizableEdge(
            edge: .top,
            initialLength: resizeLengths.initial,
            minLength: resizeLengths.min,
            maxLength: resizeLengths.max
          )
      }
      .frame(width: 180, height: 500)
      
      VStack(spacing: 0) {
        Color.orange.opacity(0.15)

        ResizableView(
          edge: .top,
          initialLength: resizeLengths.initial,
          minLength: resizeLengths.min,
          maxLength: resizeLengths.max
        ) {
          Color.brown.opacity(0.15)
          //              .frame(maxHeight: .infinity)
        }

      }
      .frame(width: 180, height: 500)
    }

    //    HStack(spacing: 0) {
    //
    //      ScrollView {
    //        Text(String(repeating: SampleContent.Strings.paragraphs[2], count: 2))
    //          .opacity(0.4)
    //      }
    //      .background(.blue.quaternary)
    //      .frame(
    //        maxWidth: .infinity,
    //        maxHeight: .infinity,
    //        alignment: .topLeading
    //      )
    //
    //      .overlay(alignment: .bottom) {
    //        OverlayView()
    //          .padding()
    //          .resizableEdge(
    //            .top,
    //            initialLength: resizeLengths.initial,
    //            minLength: resizeLengths.min,
    //            maxLength: resizeLengths.max
    //          )
    //      }
    //      Rectangle()
    //        .fill(.green.tertiary)
    //    }

  }
}

extension ResizableExampleView {
  @ViewBuilder
  private func OverlayView() -> some View {
    Rectangle()
      .fill(.thinMaterial)
      .fill(.brown.opacity(0.3))

      .frame(
        maxWidth: .infinity,
        minHeight: 100,
        maxHeight: .infinity,
        alignment: .bottom
      )
      .frame(height: overlayHeight)
      .clipShape(.rect(cornerRadius: Styles.sizeRegular))

  }
}
#if DEBUG
#Preview {
  ResizableExampleView()
    .frame(width: 500, height: 600)
}
#endif
