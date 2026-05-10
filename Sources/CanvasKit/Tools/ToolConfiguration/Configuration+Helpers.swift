//
//  Configuration+Helpers.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/5/2026.
//

import BasePrimitives
import CoreUtilities

// MARK: - Equatability

extension ToolConfiguration: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.bindings == rhs.bindings
      && lhs.springLoadDelay == rhs.springLoadDelay
      && lhs.tools.elementsEqual(rhs.tools, by: Self.toolsAreEqual)
  }

  private static func toolsAreEqual(
    _ lhs: any CanvasTool,
    _ rhs: any CanvasTool,
  ) -> Bool {
    func compare<T: CanvasTool>(_ lhs: T, to rhs: any CanvasTool) -> Bool {
      guard let rhs = rhs as? T else { return false }
      return lhs == rhs
    }

    return compare(lhs, to: rhs)
  }

}

extension ToolConfiguration: CustomStringConvertible {
  public var description: String {
    DisplayString {
      Labeled("Tools", value: tools)
      Labeled("Bindings", value: bindings)
      Labeled("Spring Load Delay", value: springLoadDelay)
    }.text
  }
}
