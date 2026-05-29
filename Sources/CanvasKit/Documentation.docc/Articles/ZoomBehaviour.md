# Zoom Behaviour

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

```swift
CanvasView(size: documentSize) {
  ArtworkView()
}
.zoomRange(0.1...12)
.zoomSensitivity(0.4)
```

## Swipe zoom

Swipe normally pans. Holding Option during a swipe interprets the vertical delta
as a zoom adjustment instead.

## Zoom tool

The built-in ``ZoomTool`` claims tap and drag:

- Tap zooms in.
- Option-tap zooms out.
- Vertical drag zooms continuously.
- Option-drag inverts the drag zoom direction.

The tool emits transform adjustments, so it works with both internally owned and
externally bound ``TransformState``.
