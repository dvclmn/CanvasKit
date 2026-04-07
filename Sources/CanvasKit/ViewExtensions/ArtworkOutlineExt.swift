//
//  ArtworkOutline.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//

@_spi(Internals) import BasePrimitives
import SwiftUI

/// I expose a public view modifier directly on ``CanvasView``:
/// `artworkOutline(colour:rounding:lineWidth:)`
/// to allow the user to easily configure the outline.
///
/// Importantly, whilst the modifier is applied to the CanvasView itself,
/// internally the outline needs to be applied to a View deeper in the
/// hierarchy, ``CanvasArtworkView``. So this modifier just sets
/// an environment value, and the value is applied where needed.
///
/// Note: See ``CanvasAddressable`` for an explanation of
/// why this is a whole ViewModifier just to set a single Env value.
public struct ArtworkOutlineModifier: ViewModifier {
//  let colour: Color
//  let rounding: Double
//  let lineWidth: Double
  
  let outline: AreaOutline

  public func body(content: Content) -> some View {
    content.environment(\.areaOutline, outline)
//    content.environment(
//      \.areaOutline,
//      AreaOutline(
//        colour: colour,
//        rounding: rounding,
//        lineWidth: lineWidth,
//      ),
//    )
  }
}
