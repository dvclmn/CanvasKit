//
//  ArtboardControlPointView.swift
//  DrawString
//
//  Created by Dave Coleman on 30/7/2025.
//


import SwiftUI

/// Note: Correct alignment (based on unit point) is handled outside
/// this view, via the `overlay` alignment argument. No need
/// for full-width/height frame with alignment assigned, in here.
struct ControlPointView<S: Shape>: View {
#if canImport(AppKit)
  @Environment(\.modifierKeys) private var modifierKeys
#endif
  @Environment(\.isDebugMode) private var isDebugMode

//  @State private var isHovering: Bool = false

  let shape: S
//  @Binding var store: ResizeHandler
//  let point: ResizePoint
  let point: UnitPoint
  let strokeWidth: CGFloat
  let length: CGFloat
  let isHovered: Bool
  
  init(
    _ shape: S = Rectangle(),
//    store: Binding<ResizeHandler>,
    point: UnitPoint,
    length: CGFloat,
    strokeWidth: CGFloat = 1.0,
    isHovered: Bool = false
  ) {
    self.shape = shape
    self.point = point
    self.strokeWidth = strokeWidth
    self.length = length
    self.isHovered = isHovered
  }

  var body: some View {

    shape
      .fill(isHovered ? .blue : .white)
    
    shape
      .stroke(
        isHovered ? .cyan : .blue,
        lineWidth: strokeWidth
      )
      .frameFromLength(length, axis: [.horizontal, .vertical])
      //      .padding(store.controlHitArea)
      //      .border(Color.green.opacity(0.3))
      //      .contentShape(.rect)
      //      .onHover { hovering in
      //        isHovering = hovering
      //        if hovering {
      //          store.hoveredResizePoint = point
      //        } else {
      //          store.hoveredResizePoint = nil
      //        }
      //      }
      .offset(point.offset(by: -length / 2))
      .allowsHitTesting(false)
  }
}
