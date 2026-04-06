//
//  ArtworkOutline.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//

import BasePrimitives
import SwiftUI

//public struct ArtworkOutlineModifier: ViewModifier {
//  let colour: Color
//  let rounding: CGFloat
//  let lineWidth: CGFloat
//
//  public func body(content: Content) -> some View {
//    content.environment(
//      \.areaOutline,
//      AreaOutline(
//        colour: colour,
//        rounding: rounding,
//        lineWidth: lineWidth,
//      ),
//    )
//  }
//}



/// Restrict to Canvas-addressable views.
extension CanvasView {
  
//  public func redTest() -> Self {
//    self.background(Color.red)
//  }
  
  
  //extension View where Self: CanvasAddressable {

  public func artworkOutline(
    colour: Color = .white.opacity(0.07),
    rounding: CGFloat = 4,
    lineWidth: CGFloat = 1,
  ) -> some View {
    self.environment(
      \.areaOutline,
      AreaOutline(
        colour: colour,
        rounding: rounding,
        lineWidth: lineWidth,
      ),
    )
    //    self.environment(\.areaOutline, <#T##V#>)
  }
  //  ) -> CanvasAddressableModified<Self, ArtworkOutlineModifier> {
  //    canvasModified(
  //      ArtworkOutlineModifier(
  //        colour: colour,
  //        rounding: rounding,
  //        lineWidth: lineWidth,
  //      )
  //    )
}

//  public func artworkOutline(
//    colour: Color = .white.opacity(0.07),
//    rounding: CGFloat? = nil,
//    lineWidth: CGFloat? = nil,
//  ) -> some View {
//    self.areaOutline(
//      colour: colour,
//      rounding: rounding,
//      lineWidth: lineWidth,
//    )
//  }

//    rounding: CGFloat = 4,
//    colour: Color = .white.opacity(0.07),
//    lineWidth: CGFloat = 1,
//  ) -> some View {
//    self.environment(
//      \.canvasArtworkOutline,
//      .init(
//        rounding: rounding,
//        colour: colour,
//        lineWidth: lineWidth,
//      ),
//    )
//  }
//}

/// Rounding and line width remain fixed regardless of zoom
