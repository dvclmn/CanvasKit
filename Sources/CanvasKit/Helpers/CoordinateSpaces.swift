//
//  NamedSpaces.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import SwiftUI

public enum ScreenSpace {
  /// Named coordinate space for the interactive viewport container.
  public static let screen: String = "canvasScreen"
}

public enum CanvasSpace {

  /// Named coordinate space for the untransformed artwork/document container.
  public static let canvas: String = "canvasArtwork"
}
