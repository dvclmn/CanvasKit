//
//  PointerEventDelivery.swift
//  CanvasKit
//
//  Created by Dave Coleman on 29/8/2026.
//

/// Stable identity for one discrete pointer-event delivery.
///
/// Tap and marquee snapshots are retained after input ends so their terminal
/// values can reach SwiftUI descendants. Their mapped coordinates may later
/// change when the artwork frame changes, but that reprojection is not new
/// physical input. Callback modifiers therefore observe this identity rather
/// than the mapped payload itself.
struct PointerEventDeliveryID: Sendable, Equatable, Hashable {
  let sequence: UInt64
}

/// Couples a mapped pointer-event value to the physical input update that
/// produced it.
///
/// The value is presentation data and may be reprojected from retained raw
/// input. `deliveryID` is the callback trigger and changes only when CanvasKit
/// accepts another discrete pointer update.
struct PointerEventDelivery<Value: Sendable>: Sendable {
  let deliveryID: PointerEventDeliveryID
  let value: Value
}

/// Delivery equality follows physical input identity rather than mapped value
/// equality. This makes the safe observation semantics part of the type itself:
/// reprojecting one retained event cannot become a new delivery accidentally.
extension PointerEventDelivery: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.deliveryID == rhs.deliveryID
  }
}
