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
| `viewportRect` | `EnvironmentValues.viewportRect` (typically set by `viewportCapture`) | ``CanvasView`` via `.task(id: viewportRect)` -> `store.updateViewportRect(...)` | Required for rendering and coordinate mapping. If `nil`, `CanvasView` currently renders fallback text. |
| `canvasSize` | ``CanvasView`` initialiser argument | ``CanvasView`` via `.task(id: canvasSize)` -> `store.updateCanvasSize(...)` | Treated as caller-owned input, mirrored into handler geometry. |
| `zoomRange` | `EnvironmentValues.zoomRange` | ``CanvasView`` via `.task(id: zoomRange)` -> `store.zoomRange = ...` | Range policy is external; current zoom value is internal. |
| `modifierKeys` | `EnvironmentValues.modifierKeys` | Consumed in GestureKit's `ZoomModifier` | Not currently stored on `CanvasHandler`. Used to stabilise pinch tracking when modifiers change. |

## Canvas-owned state (source of truth is inside CanvasKit)

`CanvasView` owns a `@State var store = CanvasHandler()`.
That handler is the runtime owner of canvas interaction state:

| State | Updated by |
|---|---|
| `panGesture` (`PanState`) | `panGesture` modifier in ``CanvasCoreView`` |
| `zoomGesture` (`ZoomState`) | `zoomGesture` modifier in ``CanvasCoreView`` |
| `rotateGesture` (`RotateState`) | (Declared, not currently wired in `CanvasCoreView`) |
| `pointerTap` (`TapState`) | `tapDragGesture` tap callback in ``CanvasCoreView`` |
| `pointerDrag` (`DragState`) | `dragRectBinding()` when drag behaviour is `.marquee` |
| `pointerHover` (`HoverState`) | `.onContinuousHover(coordinateSpace: .global)` in ``CanvasCoreView`` |
| `activeDragType` (`DragBehavior`) | Internal policy (default `.none`) |
| `geometry` (`CanvasGeometry`) | Mirrored from external `viewportRect` + `canvasSize` |

Derived canvas-owned values include `zoomClamped`, `pan`, `viewportContext`, `pointerHoverMapped`, and `pointerHoverCanvasIfInside`.

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
| Hover (`pointerHover`) | Global/screen (`.onContinuousHover(... .global)`) | Mapped to canvas via `ViewportContext` + `PointerHoverHandler` |
| Tap (`pointerTap`) | Gesture-local (from `onTapGesture`) | Not automatically mapped to canvas in CanvasKit |
| Drag rect (`pointerDrag`) | Gesture-local (from `DragGesture`) | Not automatically mapped to canvas in CanvasKit |

This difference is important: hover has an explicit global -> canvas mapping path today; tap/drag currently do not.

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
Hover point captured in global space
-> `store.pointerHover`
-> `store.viewportContext` (from geometry + pan + zoom)
-> `PointerHoverHandler.map(screenPoint:)`
-> `HoverMapping` with canvas point + inside/outside result.

## Ambiguity/correctness checklist

These are useful to keep explicit while the architecture is in flux:

1. `CanvasView` reads `modifierKeys`, but does not currently use it directly.
2. Pan callback receives modifiers, but `CanvasCoreView` currently ignores that parameter.
3. `showsInfoBar` is currently stored on `CanvasView` but not used in body composition.
4. Pointer tap/drag and hover are not yet normalised into one shared coordinate-space policy.
5. `rotateGesture` exists in `CanvasHandler`, but rotation is not currently wired through `CanvasCoreView`.
