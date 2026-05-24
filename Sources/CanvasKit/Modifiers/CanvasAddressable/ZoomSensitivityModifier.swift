//
//  ZoomSensitivityModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 8/5/2026.
//

import CoreTools
import SwiftUI

public struct ZoomSensitivityModifier: ViewModifier {

  let sensitivity: Double

  public func body(content: Content) -> some View {
    content.environment(\.zoomSensitivity, sensitivity)
  }
}

extension View where Self: CanvasAddressable {

  /// Controls pinch zoom response on a `0...1` scale.
  ///
  /// The default is `0.5`, matching CanvasKit's standard pinch response.
  /// Lower values are gentler; higher values cover more zoom range per gesture.
  public func zoomSensitivity(_ sensitivity: Double) -> ModifiedContent<Self, ZoomSensitivityModifier> {
    self.modifier(
      ZoomSensitivityModifier(
        sensitivity: sensitivity.clamped(to: 0...1)
      )
    )
  }
}
