//
//  PointerDragPayload.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 19/3/2026.
//

import Foundation

/// This is an improvement over the previous CGRect, which was
/// trying to wear too many hats
public enum PointerDragPayload: Sendable, Equatable {
  /// For panning/continuous
  case delta(Size<ScreenSpace>, location: Point<ScreenSpace>)

  /// For marquee/select
  case rect(from: Point<ScreenSpace>, current: Point<ScreenSpace>)
}

extension PointerDragPayload {

  public var name: String {
    switch self {
      case .delta(let size, let location):
        "Delta[size: \(formatSize(size)), location: \(formatPoint(location))]"
      case .rect(let from, let current): "Rect[from: \(formatPoint(from)), current: \(formatPoint(current))]"
    }
  }

  private func formatSize(_ value: Size<ScreenSpace>) -> String {
    value.cgSize.displayString(formatPreset)
  }
  private func formatPoint(_ value: Point<ScreenSpace>) -> String {
    value.cgPoint.displayString(formatPreset)
  }
  private var formatPreset: FloatDisplayPreset { .concise }

  var boundingRect: Rect<ScreenSpace>? {
    switch self {
      case .delta: nil
      case .rect(let from, let current): Rect<ScreenSpace>(from: from, to: current)
    }
  }
}
