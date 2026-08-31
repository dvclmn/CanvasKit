//
//  PointerDragConfiguration.swift
//  CanvasKit
//
//  Created by Dave Coleman on 31/8/2026.
//

import Foundation

/// Capture and presentation policy for a tool's pointer drag.
///
/// ``behaviour`` determines the shape of the delivered drag payload, while
/// ``showsMarquee`` independently controls CanvasKit's transient rectangle
/// overlay. Hiding the overlay does not suppress or otherwise change the drag
/// lifecycle published through ``CanvasDragEvent``.
public struct PointerDragConfiguration: Sendable, Equatable {
  public let behaviour: PointerDragBehaviour
  public let minimumDistance: CGFloat
  public let showsMarquee: Bool

  public init(
    behaviour: PointerDragBehaviour = .marquee,
    minimumDistance: CGFloat = 5,
    showsMarquee: Bool = true,
  ) {
    self.behaviour = behaviour
    self.minimumDistance = minimumDistance
    self.showsMarquee = behaviour.isMarquee && showsMarquee
  }
}

extension PointerDragConfiguration {
  public static let marquee: Self = .init(behaviour: .marquee)
  public static let continuous: Self = .init(behaviour: .continuous(axes: .both))
}
