//
//  PointerTapSnapshot.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/8/2026.
//

/// An internal tap event carrying delivery identity as well as location.
///
/// The identity distinguishes repeated taps at the same point and prevents a
/// retained viewport location from being redelivered merely because later
/// artwork movement maps it to a different canvas location.
struct PointerTapSnapshot<Space>: Sendable, Equatable {
  let location: Point<Space>
  let deliveryID: PointerEventDeliveryID
}
