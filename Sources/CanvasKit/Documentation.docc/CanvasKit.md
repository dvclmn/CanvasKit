# ``CanvasKit``

## State ownership and flow

This page defines which state is:

1. **incoming from outside CanvasKit**
2. **owned inside the Canvas domain**
3. **published back out for other domains**

The goal is to keep a single source of truth per state value.

## Incoming external state (source of truth is outside CanvasKit)

| State | External source | Ingestion point | Notes |
|---|---|---|---|
| `viewportRect` | `EnvironmentValues.viewportRect` (typically set by `viewportCapture`) | ``CanvasView`` via `.task(id: canvasGeometry)` -> `store.geometry = canvasGeometry` | Used for fallback legacy global mapping and zoom focus policy. |
| `canvasSize` | ``CanvasView`` initialiser argument | ``CanvasView`` via `.task(id: canvasGeometry)` -> `store.geometry = canvasGeometry` | Treated as caller-owned input, mirrored into handler geometry. |
| `zoomRange` | `EnvironmentValues.zoomRange` | ``CanvasView`` via `.task(id: zoomRange)` -> `store.zoomRange = ...` | Range policy is external; current zoom value is internal. |
| `modifierKeys` | `EnvironmentValues.modifierKeys` | Consumed in GestureKit's `ZoomModifier` | Not currently stored on `CanvasHandler`. Used to stabilise pinch tracking when modifiers change. |

## Canvas-owned state (source of truth is inside CanvasKit)

`CanvasView` owns a `@State var store = CanvasHandler()`.
That handler is the runtime owner of canvas interaction state:

| State | Updated by |
|---|---|
| `panGesture` (`PanState`) | `panGesture` modifier in ``CanvasCoreView`` |
| `onPinchGesture` (`ZoomState`) | `onPinchGesture` modifier in ``CanvasCoreView`` |
| `rotateGesture` (`RotateState`) | (Declared, not currently wired in `CanvasCoreView`) |
| `tap` (`TapState`) | `pointerDragGesture` tap callback in ``CanvasCoreView`` |
| `pointerDrag` (`DragState`) | `dragRectBinding()` when drag behaviour is `.marquee` |
| `hover` (`HoverState`) | `.onContinuousHover(coordinateSpace: .named(CanvasSpace.viewport))` in ``CanvasCoreView`` |
| `activeDragType` (`PointerDragBehaviour`) | Internal policy (default `.none`) |
| `geometry` (`CanvasGeometry`) | Mirrored from external `viewportRect` + `canvasSize` |
| `artworkFrameInViewport` (`CGRect?`) | Resolved in ``CanvasCoreView`` from `Anchor<CGRect>` emitted by ``CanvasArtwork`` |

Derived canvas-owned values include `zoomClamped`, `pan`, `CanvasViewportMapping` (legacy path), `pointerHoverMappedNative`, `pointerHoverMappedLegacy`, and `pointerHoverCanvasIfInside`.

## Published outbound state (for ancestor/child domains)

Canvas publishes state back to environment in two places:

| Published value | Set by | Downstream consumers |
|---|---|---|
| `.environment(store)` | ``CanvasView`` | Any descendant that reads `@Environment(CanvasHandler.self)` |
| `EnvironmentValues.canvasGeometry` | ``CanvasView`` | Domains needing raw viewport/canvas geometry |
| `EnvironmentValues.canvasSize` | ``CanvasView`` | Domains that need artwork/document size |
| `EnvironmentValues.panOffset` | ``CanvasCoreView`` | E.g. overlays, resize UI, grid rendering |
| `EnvironmentValues.zoomLevel` | ``CanvasCoreView`` | E.g. outline thickness, zoom-aware drawing |

## Coordinate-space contract

| Interaction value | Current coordinate space | Mapping status |
|---|---|---|
| Hover (`pointerHover`) | Viewport named space (`.named(CanvasSpace.viewport)`) | Mapped to canvas via `Anchor<CGRect>` + `GeometryProxy` resolved artwork frame (`NativePointerHoverHandler`) |
| Tap (`pointerTap`) | Viewport-local (from `onTapGesture`) | Mapped to canvas via `canvasPoint(fromViewportPoint:)` (native first, legacy fallback) |
| Drag rect (`pointerDrag`) | Gesture-local (from `DragGesture`) | Not automatically mapped to canvas in CanvasKit |

This difference is important: hover and tap now use a native-first mapping path with legacy fallback; drag rect is still local.

## Manual vs SwiftUI-native mapping

| Legacy/manual component | SwiftUI-native replacement in first pass | Notes |
|---|---|---|
| `CanvasViewportMapping.centeringOffset` + `totalGlobalOffset` | `Anchor<CGRect>` from artwork + resolve with `GeometryProxy` in viewport space | SwiftUI now gives the transformed artwork frame directly, including zoom/pan/anchor layout outcome. |
| `CanvasViewportMapping.toCanvas(screenPoint:)` | `(viewportPoint - artworkFrame.minXY) / zoom` in `NativePointerHoverHandler` | Same conversion intent, but origin source is native resolved frame, not recomputed maths. |
| `PointerHoverHandler(context:)` | `NativePointerHoverHandler(artworkFrameInViewport:canvasSize:zoom:)` | Both currently run side-by-side for one-to-one comparison. |
| `.coordinateSpace(.named(CanvasSpace.safeArea))` on artwork only | `.coordinateSpace(.named(CanvasSpace.viewport))` on ``CanvasCoreView`` + `.coordinateSpace(.named(CanvasSpace.artwork))` on ``CanvasArtwork`` | Named spaces are now placed where gesture capture and artwork identity live. |
| Implicit frame derivation from env values | `ArtworkBoundsAnchorKey` + `overlayPreferenceValue` | Uses anchor preferences to propagate bounds up tree and resolve in ancestor space. |

## Migration instrumentation

The handler now exposes both mappings:

- `pointerHoverMappedNative`
- `pointerHoverMappedLegacy`
- `pointerHoverMapped` (native preferred, legacy fallback)

In debug builds, `pointerHoverMappingComparison` reports canvas drift and round-trip errors between the two paths.

## Flow examples

### 1) External viewport change
`viewportCapture` updates `EnvironmentValues.viewportRect`
-> ``CanvasView`` task updates `store.geometry.viewportRect`
-> descendants can read updated `canvasGeometry` from environment.

### 2) Two-finger pan
Trackpad delta arrives in GestureKit pan modifier
-> `store.panGesture.updateDelta(...)`
-> `store.pan` is republished as `EnvironmentValues.panOffset`
-> artwork offset updates in ``CanvasArtwork``.

### 3) Pointer hover mapping
Hover point captured in viewport named space
-> `store.pointerHover`
-> `CanvasArtwork` emits `.bounds` anchor via `ArtworkBoundsAnchorKey`
-> `CanvasCoreView` resolves anchor with `GeometryProxy` into `artworkFrameInViewport`
-> `NativePointerHoverHandler.map(viewportPoint:)`
-> `HoverMapping` with canvas point + inside/outside result.

## Ambiguity/correctness checklist

These are useful to keep explicit while the architecture is in flux:

1. `CanvasView` reads `modifierKeys`, but does not currently use it directly.
2. Pan callback receives modifiers, but `CanvasCoreView` currently ignores that parameter.
3. `showsInfoBar` is currently stored on `CanvasView` but not used in body composition.
4. Drag rect is not yet normalised into the same native mapping path as hover/tap.
5. `rotateGesture` exists in `CanvasHandler`, but rotation is not currently wired through `CanvasCoreView`.
