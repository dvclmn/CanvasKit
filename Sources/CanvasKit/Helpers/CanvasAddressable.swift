//
//  CanvasAddressable.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//

import SwiftUI

extension CanvasView {
  public func zoomRange(_ range: ClosedRange<Double>) -> some View {
    self.environment(\.zoomRange, range)
  }
}

public protocol CanvasAddressable {}

/// Preserve CanvasAddressable across SwiftUI modifiers.
extension ModifiedContent: CanvasAddressable where Content: CanvasAddressable {}

public struct CanvasModified<Content: View & CanvasAddressable, Modifier: ViewModifier>: View,
  CanvasAddressable
{
  let content: Content
  let modifier: Modifier

  public init(
    content: Content,
    modifier: Modifier
  ) {
    self.content = content
    self.modifier = modifier
  }

  public var body: some View {
    content.modifier(modifier)
  }
}

extension View where Self: CanvasAddressable {
  func canvasModified<M: ViewModifier>(_ modifier: M) -> CanvasModified<Self, M> {
    CanvasModified(content: self, modifier: modifier)
  }
}
