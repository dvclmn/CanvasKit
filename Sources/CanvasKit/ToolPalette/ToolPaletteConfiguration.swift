//
//  ToolPaletteConfiguration.swift
//  CanvasKit
//
//  Created by Dave Coleman on 27/8/2026.
//

import SwiftUI

extension EnvironmentValues {
  @Entry var toolPaletteConfiguration: ToolPaletteConfiguration = .init()
}

public struct ToolPaletteConfiguration: Sendable, Equatable {

  let alignment: Alignment

  /// The total width including padding
  let width: CGFloat

  let paddingH: CGFloat

  public init(
    alignment: Alignment = Self.defaultAlignment,
    width: CGFloat = Self.defaultWidth,
    paddingH: CGFloat = Self.defaultPaddingH,
  ) {
    self.alignment = alignment
    self.width = width
    self.paddingH = paddingH
  }
}

extension ToolPaletteConfiguration {
  public static let defaultAlignment: Alignment = .topLeading
  public static let defaultWidth: CGFloat = 36
  public static let defaultPaddingH: CGFloat = 6
}
