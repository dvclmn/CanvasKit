//
//  PanDragGesture.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

//import SwiftUI

#warning("I think this has been superceded by PointerDragModifer?")
/// A drag modifier that accumulates offset across multiple drag gestures.
///
/// Unlike a plain `DragGesture`, each new drag begins from the offset left by the
/// previous one, so movement compounds over time. Internally powered by
/// ``DragGestureState`` with ``DragBehavior/continuous(_:)``.
///
/// Prefer ``View/cumulativeDrag(_:isEnabled:minDragDistance:isDragging:)``
/// over constructing this modifier directly.
//struct CumulativeDragGestureModifier: ViewModifier {
//
//  @State private var dragState: DragGestureState
//  @Binding var offset: CGSize
//  let isEnabled: Bool
//  let minDragDistance: CGFloat
//  let isDragging: (Bool) -> Void
//
//  init(
//    offset: Binding<CGSize>,
//    axes: GridAxis.Set = .all,
//    isEnabled: Bool,
//    minDragDistance: CGFloat,
//    isDragging: @escaping (Bool) -> Void
//  ) {
//    self._offset = offset
//    self._dragState = State(
//      initialValue: DragGestureState(.continuous(axes: axes))
//    )
//    self.isEnabled = isEnabled
//    self.minDragDistance = minDragDistance
//    self.isDragging = isDragging
//  }
//
//  func body(content: Content) -> some View {
//    content
//      .gesture(dragGesture, isEnabled: isEnabled)
//  }
//}
//
//extension CumulativeDragGestureModifier {
//  private var dragGesture: some Gesture {
//    DragGesture(minimumDistance: minDragDistance)
//      .onChanged { value in
//
//        /// Anchor once at the start of each drag so translation is relative to
//        /// the offset committed by the previous drag gesture.
//        if dragState.anchor == nil {
//          dragState.begin(with: offset.toCGPoint)
//        }
//
//        if let result = dragState.update(value) {
//          offset = result.size
//        }
//
//        isDragging(true)
//      }
//
//      .onEnded { _ in
//        dragState.end()
//        isDragging(false)
//      }
//  }
//}
//
//extension View {
//  /// Adds a cumulative drag gesture that compounds offset across successive drags.
//  ///
//  /// Lifting and re-dragging resumes from where the previous drag stopped,
//  /// unlike a basic `DragGesture` which always resets to zero translation.
//  ///
//  /// - Parameters:
//  ///   - offset: Binding that receives the accumulated `CGSize` offset.
//  ///   - isEnabled: When `false`, the gesture is ignored entirely.
//  ///   - minDragDistance: Minimum movement before the drag activates (default `5` pt).
//  ///   - isDragging: Called with `true` while dragging, `false` on release.
//  public func cumulativeDrag(
//    _ offset: Binding<CGSize>,
//    isEnabled: Bool = true,
//    minDragDistance: CGFloat = 5,
//    isDragging: @escaping (Bool) -> Void = { _ in }
//  ) -> some View {
//    self.modifier(
//      CumulativeDragGestureModifier(
//        offset: offset,
//        isEnabled: isEnabled,
//        minDragDistance: minDragDistance,
//        isDragging: isDragging
//      )
//    )
//  }
//}
