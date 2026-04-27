//
//  ToolKind.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import Foundation

/// An extensible tool identity. New tools can be defined by extending this type:
/// ```swift
/// extension CanvasToolKind {
///   public static let brush = Self("brush")
/// }
/// ```
public struct CanvasToolKind: RawRepresentable, Hashable, Sendable, Equatable, ExpressibleByStringLiteral {
  public let rawValue: String

  public init(rawValue: String) { self.rawValue = rawValue }

  public init(_ rawValue: String) {
    self.init(rawValue: rawValue)
  }

  public init(stringLiteral value: String) {
    self.init(value)
  }
}

extension CanvasToolKind: CustomStringConvertible {
  public var description: String { rawValue }
}
