//
//  CanvasAddressable.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//



//public struct GreenTestModifier: ViewModifier {
//  public func body(content: Content) -> some View {
//    content
//      .background(.green)
//  }
//}
//public struct BlurTestModifier: ViewModifier {
//  public func body(content: Content) -> some View {
//    content
//      .blur(radius: 50)
//  }
//}



/// Restrict to Canvas-addressable views.
//extension View where Self: CanvasAddressable {
  
//  public func greenTest() -> ModifiedContent<Self, GreenTestModifier>  {
//    self.modifier(GreenTestModifier())
//  }
//  public func blurTest() -> ModifiedContent<Self, BlurTestModifier>  {
//    self.modifier(BlurTestModifier())
//  }

//}
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
