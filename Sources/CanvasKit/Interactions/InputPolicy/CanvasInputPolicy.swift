//
//  CanvasInputPolicy.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 10/3/2026.
//

//import InteractionKit

/// Controls which input modifiers and gestures are active on the canvas.
///
/// Each tool declares its own `inputPolicy`, which is pushed into the
/// environment by `InteractionStateSetupModifier`. The policy gates
/// gesture modifiers in `InteractionModifiers`:
//public struct CanvasInputPolicy: Equatable, Sendable {
//
//  public var activeInputs: ActiveInputs
//
//  /// The drag interaction mode
//  public var dragBehaviour: DragBehavior
//
//  public init(
//    activeInputs: ActiveInputs = .all,
//    dragBehaviour: DragBehavior = .none,
//
//  ) {
//    self.activeInputs = activeInputs
//    self.dragBehaviour = dragBehaviour
//  }
//
//  public static let initial = CanvasInputPolicy()
//}

//extension CanvasInputPolicy: CustomStringConvertible {
//  public var description: String {
//    DisplayString {
//      Indented {
//        Labeled("Active Inputs", value: activeInputs.stringValueJoined())
//        Labeled("Drag behaviour", value: dragBehaviour.name)
//      }
//    }.text
//  }
//}
