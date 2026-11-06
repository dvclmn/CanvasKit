//
//  ToolPaletteConfiguration.swift
//  CanvasKit
//
//  Created by Dave Coleman on 27/8/2026.
//

import SwiftUI
internal import ViewTools

public struct ToolPaletteConfiguration: Sendable, Equatable {

  let alignment: Alignment

  /// The total outer width, including padding
  let width: CGFloat

  let paddingH: CGFloat

  let glass: GlassTypeCompatible

  public init(
    alignment: Alignment = Self.defaultAlignment,
    width: CGFloat = Self.defaultWidth,
    paddingH: CGFloat = Self.defaultPaddingH,
  ) {
    self.alignment = alignment
    self.width = width
    self.paddingH = paddingH
    self.glass = .regular
  }
}

extension ToolPaletteConfiguration {
  public static let defaultAlignment: Alignment = .topLeading
  public static let defaultWidth: CGFloat = 44
  public static let defaultPaddingH: CGFloat = 5
}

@available(anyAppleOS 26.0, *)
extension ToolPaletteConfiguration {
  public init(
    alignment: Alignment = Self.defaultAlignment,
    width: CGFloat = Self.defaultWidth,
    paddingH: CGFloat = Self.defaultPaddingH,
    glass: Glass = .regular
  ) {
    self.alignment = alignment
    self.width = width
    self.paddingH = paddingH
    self.glass = GlassTypeCompatible(glass: glass)
  }
}
