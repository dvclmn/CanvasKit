//
//  ResizableModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 21/2/2026.
//


import SwiftUI

struct ResizableEdgeModifier: ViewModifier {
  @State private var currentLength: CGFloat
  @State private var dragDelta: CGFloat = .zero

  let state: ResizeState

  init(
    initialLength: CGFloat,
    state: ResizeState
  ) {
    self._currentLength = State(initialValue: initialLength)
    self.state = state
  }

  init(
    edge: Edge,
    initialLength: CGFloat,
    minLength: CGFloat,
    maxLength: CGFloat
  ) {
    self._currentLength = State(initialValue: initialLength)
    self.state = ResizeState(edge: edge, minLength: minLength, maxLength: maxLength)
  }

  func body(content: Content) -> some View {
    content
      .frame(
        maxWidth: .infinity,
        maxHeight: .infinity,
        alignment: state.edge.toAlignment.toOpposing
      )
      .frame(
        width: state.isVertical ? nil : displaySize,
        height: state.isVertical ? displaySize : nil,
        alignment: state.edge.toAlignment.toOpposing
      )
      .overlay(alignment: state.edge.toAlignment) {
        ResizeHandle()
          .gesture(
            ResizeGesture(
              currentLength: $currentLength,
              state: state
            ) { delta in
              dragDelta = delta
            }
          )
          .environment(\.layoutAxis, state.edge.toAxis)
      }
  }
}

extension ResizableEdgeModifier {
  private var displaySize: CGFloat {
    state.displaySize(currentLength: currentLength, dragDelta: dragDelta)
  }

}

extension View {
  public func resizableEdge(
    edge: Edge,
    initialLength: CGFloat,
    minLength: CGFloat = 100,
    maxLength: CGFloat = 600
  ) -> some View {
    modifier(
      ResizableEdgeModifier(
        edge: edge,
        initialLength: initialLength,
        minLength: minLength,
        maxLength: maxLength
      )
    )
  }
}
