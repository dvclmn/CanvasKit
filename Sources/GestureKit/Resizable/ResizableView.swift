//
//  ResizableView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 22/2/2026.
//

import SwiftUI

public struct ResizableView<Content: View>: View {
  @State private var currentLength: CGFloat

  let state: ResizeState
  let content: () -> Content

  public init(
    edge: Edge,
    initialLength: CGFloat,
    minLength: CGFloat,
    maxLength: CGFloat,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self._currentLength = State(initialValue: initialLength)
    self.state = ResizeState(edge: edge, minLength: minLength, maxLength: maxLength)
    self.content = content
  }

  public var body: some View {
    content()
      .modifier(
        ResizableEdgeModifier(
          initialLength: currentLength,
          state: state
        )
      )
  }
}
