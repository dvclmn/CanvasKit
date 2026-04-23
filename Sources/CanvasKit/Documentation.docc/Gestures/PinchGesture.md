# Pinch Gesture

Converts `MagnifyGesture` into incremental zoom deltas and
routes them through one of two ownership modes:

## Mode A — Binding
```swift
.onPinchGesture(zoom: $myZoom)
```
The modifier owns the gesture math, clamps to `zoomRange`, and writes the
result directly to the binding. No override callback — the binding is the
single source of truth.

## Mode B — Event callback
```swift
.onPinchGesture(initial: currentZoom, didUpdateZoom: { event in ... })
```
The modifier tracks deltas internally, but the **caller** owns the zoom
value. The callback receives a ``ZoomGestureEvent`` and returns the
resolved zoom (or `nil` to accept the proposal). The caller is responsible
for writing the result to its own state.

> Important: Do **not** combine a binding with an override callback.
> That creates two writers for the same value and leads to double-writes.
> Use Mode A *or* Mode B, not both.
