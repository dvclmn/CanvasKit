//
//  CanvasAddressable.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//

import SwiftUI

public protocol CanvasAddressable {}

/// Preserve CanvasAddressable across SwiftUI modifiers.
extension ModifiedContent: CanvasAddressable where Content: CanvasAddressable {}

//public struct CanvasModified<Content: View & CanvasAddressable, Modifier: ViewModifier>: View,
//  CanvasAddressable
//{
//  let content: Content
//  let modifier: Modifier
//
//  public init(
//    content: Content,
//    modifier: Modifier
//  ) {
//    self.content = content
//    self.modifier = modifier
//  }
//
//  public var body: some View {
//    content.modifier(modifier)
//  }
//}

//extension View where Self: CanvasAddressable {
//  func canvasModified<M: ViewModifier>(_ modifier: M) -> CanvasModified<Self, M> {
//    CanvasModified(content: self, modifier: modifier)
//  }
//}


//extension CanvasView {
//  public func zoomRange(_ range: ClosedRange<Double>) -> some View {
//    self.environment(\.zoomRange, range)
//  }
//}


//public struct ArtworkOutlineModifier: ViewModifier {
//  let colour: Color
//  let rounding: CGFloat
//  let lineWidth: CGFloat
//  
//  public func body(content: Content) -> some View {
//    content.environment(
//      \.areaOutline,
//       AreaOutline(
//        colour: colour,
//        rounding: rounding,
//        lineWidth: lineWidth,
//       ),
//    )
//  }
//}

public struct GreenTestModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .background(.green)
  }
}
public struct BlurTestModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .blur(radius: 50)
  }
}



/// Restrict to Canvas-addressable views.
extension View where Self: CanvasAddressable {
  
  public func greenTest() -> ModifiedContent<Self, GreenTestModifier>  {
    self.modifier(GreenTestModifier())
  }
  public func blurTest() -> ModifiedContent<Self, BlurTestModifier>  {
    self.modifier(BlurTestModifier())
  }
  
//  public func blurTest() -> CanvasModified<Self, BlurTestModifier> {
//    canvasModified(BlurTestModifier())
//  }
}
  //  public func artworkOutline(
  //    colour: Color = .white.opacity(0.07),
  //    rounding: CGFloat = 4,
  //    lineWidth: CGFloat = 1,
  //  ) -> CanvasModified<Self, ArtworkOutlineModifier> {
  //    canvasModified(
  //      ArtworkOutlineModifier(
  //        colour: colour,
  //        rounding: rounding,
  //        lineWidth: lineWidth,
  //      )
  //    )
  //  }
  
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
