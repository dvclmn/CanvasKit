//
//  CanvasInteractionActivity.swift
//  CanvasKit
//
//  Created by Dave Coleman on 28/8/2026.
//

/// A snapshot of the interaction kinds currently active within a ``CanvasView``.
///
/// This value contains current activity rather than the most recent interaction
/// event. A kind is removed when its interaction ends or is cancelled, while
/// other simultaneously active kinds remain present.
public struct CanvasInteractionActivity: Sendable, Equatable {
  /// The input kinds whose lifecycle phase is currently active.
  public let activeKinds: Set<Interaction.Kind>

  /// A snapshot with no active interaction kinds.
  public static let none = Self(activeKinds: [])

  /// Creates a snapshot containing the supplied active interaction kinds.
  ///
  /// This initializer also allows callers to override the corresponding
  /// Environment value in previews and focused view tests.
  public init(activeKinds: Set<Interaction.Kind>) {
    self.activeKinds = activeKinds
  }

  /// Whether at least one interaction kind is active.
  public var isActive: Bool {
    !activeKinds.isEmpty
  }

  /// Returns whether `kind` is currently active.
  public func contains(_ kind: Interaction.Kind) -> Bool {
    activeKinds.contains(kind)
  }

  /// Whether a viewport swipe is currently active.
  public var isSwipeActive: Bool {
    contains(.swipe)
  }

  /// Whether a tool-routed pointer drag is currently active.
  public var isDragActive: Bool {
    contains(.drag)
  }
}
