# Zoom Behaviour

CanvasKit provides multiple ways to adjust zoom, supporting gestures and tools for smooth, predictable scaling. This article explains each supported zoom interaction and how zoom values are managed.

CanvasKit has three current zoom paths:

- Pinch gestures.
- Option-swipe gestures.
- The built-in ``ZoomTool``.

All committed zoom values are clamped to the current `zoomRange`.

## Pinch zoom

Pinch gestures are backed by SwiftUI `MagnifyGesture`. CanvasKit tracks the gesture start zoom, converts magnification into a proposed absolute zoom, then commits the resolved value.

`zoomSensitivity(_:)` controls the response curve on a `0...1` scale. Lower values are gentler; higher values cover more zoom range per gesture.

### Proposal and resolution

``ZoomProposal`` is analogous to a SwiftUI layout proposal in one useful respect: it is a candidate offered to another policy boundary, not a command or a second source of truth. The analogy stops there; `ZoomProposal` is a CanvasKit interaction value and is unrelated to SwiftUI's layout protocol.

Use the binding overload when an external model owns zoom. The binding supplies the initial value, receives committed gesture values, and can change the zoom programmatically while no pinch is active.

```swift
ArtworkView()
  .onPinchGesture(zoom: $zoom) { proposal in
    proposal.proposedZoom
  }
```

Use the internally owned overload when the modifier should retain the working zoom itself. `initialZoom` is only the seed for the first gesture; the resolver's returned value becomes the basis for subsequent updates.

```swift
ArtworkView()
  .onPinchGesture(initialZoom: 1) { proposal in
    analytics.record(proposal)
    return proposal.proposedZoom
  }
```

The resolver runs before CanvasKit's final `zoomRange` clamp. It may accept `proposal.proposedZoom` unchanged or replace it with an app-specific value.

### Binding conflict policy

The external binding is authoritative when the modifier appears and whenever no pinch is active. An active pinch temporarily owns the working zoom so a concurrent programmatic binding write cannot reset the gesture halfway through. CanvasKit therefore does not adopt external changes received during an active pinch; the next resolved gesture value may overwrite such a change. Disable the pinch before performing a programmatic update when that update must interrupt an active gesture.

For non-zoom mappings, ``SwiftUI/View/onViewportPinch(isEnabled:perform:)`` exposes neutral start-relative and incremental magnification without applying CanvasKit's zoom sensitivity or range policy.

```swift
CanvasView(size: documentSize) {
  ArtworkView()
}
.zoomRange(0.1...12)
.zoomSensitivity(0.4)
```
