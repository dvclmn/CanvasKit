//
//  PointerTapSnapshot.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/8/2026.
//

/// An internal tap event carrying identity as well as location.
///
/// The sequence distinguishes repeated taps at the same point so SwiftUI
/// environment observation does not collapse them as equal state assignments.
struct PointerTapSnapshot<Space>: Sendable, Equatable {
  let location: Point<Space>
  let sequence: UInt64
}
