//
//  Size.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 3/3/2026.
//

import Foundation

/// Allows differentiating one `CGSize` from another, to make it clearer
/// and easier to move between different coordinate spaces, with compile-time safety.
public struct Size<Space>: Sendable, Equatable {
  public var width: CGFloat
  public var height: CGFloat

  public init(width: CGFloat, height: CGFloat) {
    self.width = width
    self.height = height
  }
}

extension Size {
  public init(fromCGSize size: CGSize) {
    self.init(width: size.width, height: size.height)
  }

  public var cgSize: CGSize {
    .init(width: width, height: height)
  }

  public static var zero: Self { .init(width: 0, height: 0) }

  public var toRectZeroOrigin: Rect<Space> {
    Rect<Space>(
      origin: .zero,
      size: self,
    )
  }

  public var toCGRectZeroOrigin: CGRect { .init(origin: .zero, size: cgSize) }
}

extension CGSize {
  public var screenSize: Size<ScreenSpace> { .init(fromCGSize: self) }

  public init<Space>(fromSize size: Size<Space>) {
    self.init(width: size.width, height: size.height)
  }
}
