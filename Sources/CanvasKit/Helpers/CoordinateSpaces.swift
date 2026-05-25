//
//  NamedSpaces.swift
//  CanvasKit
//
//  Created by Dave Coleman on 28/2/2026.
//

import SwiftUI

public enum ViewportSpace {
  /// Named coordinate space for the interactive viewport container.
  public static let viewport: String = "canvasScreen"
}

public enum CanvasSpace {

  /// Named coordinate space for the untransformed artwork/document container.
  public static let canvas: String = "canvasArtwork"
}

extension CGRect {
  public var viewportRect: Rect<ViewportSpace> { .init(fromRect: self) }
}

extension CGPoint {
  public var viewportPoint: Point<ViewportSpace> { .init(fromPoint: self) }
}

extension CGSize {
  public var viewportSize: Size<ViewportSpace> {
    .init(fromCGSize: self)
  }

}
