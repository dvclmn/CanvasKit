# Zoom Behaviour

CanvasKit provides multiple ways to adjust zoom, supporting gestures and tools for smooth, predictable scaling. This article explains each supported zoom interaction and how zoom values are managed.

CanvasKit has three current zoom paths:

- Pinch gestures.
- Option-swipe gestures.
- The built-in ``ZoomTool``.

All committed zoom values are clamped to the current `zoomRange`.

## Pinch zoom

Pinch gestures are backed by SwiftUI `MagnifyGesture`. CanvasKit tracks the
gesture start zoom, converts magnification into a proposed absolute zoom, then
commits the resolved value.

`zoomSensitivity(_:)` controls the response curve on a `0...1` scale. Lower
values are gentler; higher values cover more zoom range per gesture.

For non-zoom mappings, ``SwiftUI/View/onViewportPinch(isEnabled:perform:)`` exposes neutral start-relative and incremental magnification without applying CanvasKit's zoom sensitivity or range policy.

```swift
CanvasView(size: documentSize) {
  ArtworkView()
}
.zoomRange(0.1...12)
.zoomSensitivity(0.4)
