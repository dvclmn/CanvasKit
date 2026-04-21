//
//  ArtworkOutline.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//

import CanvasCore
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

  let outline: AreaOutline

  public func body(content: Content) -> some View {
    content.environment(\.artworkOutline, outline)
  }
}

extension View where Self: CanvasAddressable {
  public func artworkOutline(
    colour: Color = .white.opacity(0.07),
    rounding: Double = 4,
    lineWidth: Double = 1,
  ) -> ModifiedContent<Self, ArtworkOutlineModifier> {
    self.modifier(
      ArtworkOutlineModifier(
        outline: .init(
          colour: colour,
          rounding: rounding,
          lineWidth: lineWidth,
        )
      )
    )
  }
}
