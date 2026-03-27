//
//  ToolKind.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 12/3/2026.
//

import Foundation

/// An extensible tool identity type — same pattern as `Notification.Name`.
///
/// Define new kinds by extending this type in any module:
/// ```swift
/// extension CanvasToolKind {
///   public static let brush = Self(rawValue: "brush")
/// }
/// ```
public struct CanvasToolKind: RawRepresentable, Hashable, Sendable {
  public let rawValue: String
  public init(rawValue: String) { self.rawValue = rawValue }
}

extension CanvasToolKind {
  public static let select = Self(rawValue: "select")
  public static let pan = Self(rawValue: "pan")
  public static let zoom = Self(rawValue: "zoom")
}
