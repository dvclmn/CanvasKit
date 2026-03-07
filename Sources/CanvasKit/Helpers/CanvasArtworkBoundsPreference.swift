//
//  CanvasArtworkBoundsPreference.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 6/3/2026.
//

import SwiftUI

struct CanvasArtworkBoundsAnchorKey: PreferenceKey {
  static let defaultValue: Anchor<CGRect>? = nil

  static func reduce(
    value: inout Anchor<CGRect>?,
    nextValue: () -> Anchor<CGRect>?
  ) {
    value = nextValue() ?? value
  }
}
