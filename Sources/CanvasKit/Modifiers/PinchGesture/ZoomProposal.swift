//
//  ZoomProposal.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/8/2026.
//

/// A candidate absolute zoom produced by a pinch gesture.
///
/// CanvasKit calculates ``proposedZoom`` from the gesture's starting zoom,
/// magnification, and current zoom sensitivity. A pinch resolver can accept
/// that candidate or return a replacement value. CanvasKit clamps the resolved
/// value to the current zoom range before committing it.
public struct ZoomProposal: Sendable, Equatable {
  /// The candidate absolute zoom before app-specific resolution and final clamping.
  public let proposedZoom: Double

  /// The lifecycle phase associated with the candidate.
  public let phase: InteractionPhase

  public init(
    proposedZoom: Double,
    phase: InteractionPhase,
  ) {
    self.proposedZoom = proposedZoom
    self.phase = phase
  }
}

/// Resolves a pinch gesture's candidate zoom into the value CanvasKit should commit.
public typealias ZoomResolver = (ZoomProposal) -> Double
