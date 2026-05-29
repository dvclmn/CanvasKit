# Transform State Ownership

CanvasKit can own pan and zoom internally, or it can mirror those values into
state owned by your app.

## Internal ownership

When no transform binding is supplied, ``CanvasView`` keeps its
``TransformState`` inside its internal handler. This is the smallest setup and
works well when other parts of the app do not need to inspect or mutate the
viewport transform.

```swift
CanvasView(size: documentSize) {
  ArtworkView()
}
```

## External ownership

Pass a binding when the transform belongs to document state, undo/redo,
inspector UI, or another part of your app. CanvasKit still processes input
locally, then keeps the binding and local model in sync.

```swift
@State private var transform = TransformState()

CanvasView(
  size: documentSize,
  transform: $transform
) {
  ArtworkView()
}
```

External ownership is useful for programmatic operations:

```swift
Button("Reset View") {
  transform.reset()
}
```

## Coordinate mapping

Pass `coordinateSpaceMapper` when app code needs to convert viewport-space
values into canvas-space values outside the canvas view hierarchy.

```swift
@State private var mapper: CoordinateSpaceMapper?

CanvasView(
  size: documentSize,
  transform: $transform,
  coordinateSpaceMapper: $mapper
) {
  ArtworkView()
}
```

The mapper becomes non-`nil` once SwiftUI has resolved the artwork frame. It is
cleared when the canvas disappears.

Descendant views can also read the same mapper from the
`canvasCoordinateSpaceMapper` environment value.
