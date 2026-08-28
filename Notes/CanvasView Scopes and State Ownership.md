# CanvasView Scopes and State Ownership

> Working architecture note, 28/8/2026. This captures current design thinking rather than a settled public API. It may later form the basis of a CanvasKit DocC article.

## Why this matters

As CanvasKit gains useful interaction and presentation features, each addition raises a recurring question: where should consumers be able to reach the resulting state or behaviour?

Views inside `CanvasView` can receive CanvasKit context naturally through the SwiftUI Environment. Views outside that subtree cannot, because Environment values propagate down the view hierarchy rather than outward to ancestors or sideways to siblings. That can lead to a new optional binding being added whenever a toolbar, overlay, inspector, command, or external input system needs to know something about the canvas.

The underlying problem is not merely how to expose more state. CanvasKit needs a clear model for spatial scope, state ownership, lifetime, and data-flow direction. A clear model should make common uses easier without turning `CanvasView` into a catalogue of every possible integration.

## The three spatial scopes

### Canvas-external or host scope

This scope contains ancestors and siblings of `CanvasView`, including application chrome, toolbars, inspectors, commands, external input systems, and container-owned overlays.

“Host” is more accurate than “app-level”. State outside `CanvasView` may be local to the immediate container rather than stored in an application-wide model. The defining property is that the consumer lives outside CanvasView's contextual subtree.

### Canvas viewport scope

This scope belongs to a particular canvas viewport but remains fixed while the artwork pans, zooms, or rotates. Possible examples include preview UI, rulers, interaction indicators, selection information, or other canvas-local chrome.

Viewport content should normally use `ViewportSpace`, remain clipped to the viewport where appropriate, and be able to receive CanvasKit Environment values. Whether it participates in hit testing depends on the overlay's purpose.

### Canvas artwork scope

This is the transformed document or artwork content. It participates in `CanvasSpace` and moves with the canvas transform.

Artwork descendants are the natural consumers of values that directly affect drawing and projection, such as zoom, pan, mapped pointer events, grid geometry, and artwork-relative interaction callbacks.

## The scopes are spatial, not ownership categories

The three scopes answer **where a view lives**. They do not by themselves answer **who owns a value**.

A useful CanvasKit design review should consider three independent axes:

| Question | Examples | Likely API mechanism |
| --- | --- | --- |
| Where is the consuming UI? | Outside CanvasView, fixed in the viewport, or transformed with the artwork | View hierarchy and view-builder structure |
| Who owns the value and its lifetime? | CanvasKit, the immediate canvas host, or the app/document | Internal state, local `@State`, a parent model, or a `Binding` |
| In which direction does the data travel? | Down to descendants, into CanvasKit, or outward from CanvasKit | Environment, value/binding input, or an observation callback/output |

This distinction prevents a spatial problem from being solved with unnecessarily broad state ownership. A view can need CanvasKit context without that context becoming application state.

```text
Canvas-external / host scope
└── CanvasView
    └── Canvas viewport scope (fixed, ViewportSpace)
        ├── Canvas artwork scope (transformed, CanvasSpace)
        └── Consumer viewport overlay (fixed)
```

## What the current applications demonstrate

### DrawString

DrawString currently demonstrates all three concerns:

- `CanvasEditorView` owns its `TransformState` as local `@State`. The transform belongs to this canvas host and does not need to be application-wide.
- `AppHandler` owns the committed `ToolSelection` because controls and presentation outside the canvas need to inspect and change the selected tool.
- Grid artwork and grid-event modifiers live inside the artwork closure, where they receive CanvasKit and GridKit context.
- `PreviewCharacterView` is attached outside the returned grid canvas as a fixed overlay. Spatially, it is canvas viewport content: it belongs to this canvas, should not transform with the artwork, and now has a reason to read `CanvasInteractionActivity` so it can hide while the user is swiping.

This makes the character preview a strong motivating case for a public viewport overlay builder. Moving the preview into the viewport scope could give it the context it needs without lifting transient interaction activity into `CanvasEditorView` or `AppHandler`.

### Paperbark

Paperbark demonstrates genuine canvas-external coordination:

- `AppHandler` stores the canvas transform and current `CoordinateSpaceMapper`.
- The external trackpad input system reads the transform when configuring input mapping.
- Trackpad touch positions are converted into canvas positions using the mapper produced by CanvasKit.
- Toolbar or command UI may also inspect or change the transform.

A viewport overlay builder does not solve this case. The relevant consumer is an input system outside CanvasView, so CanvasKit needs an explicit outward-facing observation channel. The transform is shared mutable state; the coordinate mapper is a CanvasKit-derived output.

### SVGEditor

SVGEditor demonstrates host-owned lifetime without app-wide ownership:

- `SVGCanvasContainer` owns its transform as local `@State`.
- That state survives changes between parsed, parsing, failed, and unavailable canvas presentations.
- Parsing and drop-target overlays are fixed host UI outside the transformed artwork.
- Those overlays do not currently need CanvasKit interaction context, so they do not need to move into a viewport overlay merely because one exists.

This example is an important reminder that an externally supplied binding may preserve the lifetime of state across child replacement without implying that the value belongs in an application model.

## The existing internal structure already contains two canvas layers

CanvasKit already distinguishes the viewport and artwork internally:

- `CanvasCoreView` establishes the fixed, clipped viewport and names `ViewportSpace`.
- `CanvasArtwork` establishes `CanvasSpace`, captures artwork bounds, and then applies scale, rotation, and translation.
- `CanvasView` owns the surrounding input modifiers, pointer handling, tool palette, Environment publication, and external synchronisation.

The current public content builder exposes only the artwork layer. A viewport overlay builder would therefore expose a real existing semantic layer rather than inventing a new architectural concept.

## The semantic mixture in the current CanvasView initialiser

The current `CanvasView` initialiser places several superficially similar optional parameters together:

```swift
CanvasView(
  size: canvasSize,
  transform: $transform,
  coordinateSpaceMapper: $coordinateSpaceMapper,
  pointerStyle: $pointerStyle,
  toolConfiguration: toolConfiguration,
  toolSelection: $toolSelection,
) {
  ArtworkView()
}
```

The parameters do not all have the same ownership or data-flow semantics.

### Plain configuration inputs

`size` and `toolConfiguration` are values supplied to CanvasKit. CanvasKit consumes them but does not use their parameters as outward observation channels.

### Parent-owned, bidirectional state

`transform` and `toolSelection` are durable values that a parent may read and change:

- CanvasKit changes the transform in response to interaction, while the parent may change it programmatically.
- The parent owns committed tool selection, while CanvasKit normalises and synchronises it. Transient key-held tool overrides remain internal to CanvasKit.

Here, `Binding` communicates a genuine shared-state contract with a parent-owned source of truth.

### CanvasKit-derived outputs transported through Binding

`coordinateSpaceMapper` and `pointerStyle` are different:

- CanvasKit derives the mapper from current canvas geometry.
- CanvasKit resolves the pointer style from the active tool and interaction context.
- CanvasKit writes these values outward and clears them when the canvas disappears.
- The consumer is not normally expected to assign an arbitrary mapper or pointer style back into CanvasKit.

These parameters use `Binding` as an output transport, but the binding syntax normally suggests that the caller owns writable state. Consequently, two parameters can look alike at the call site while communicating different authority:

```swift
transform: $transform                         // Parent controls and observes.
coordinateSpaceMapper: $coordinateSpaceMapper // Parent observes CanvasKit's output.
```

That is the “slight semantic mixture”: not that any individual feature is wrong, but that one initialiser combines configuration, parent-owned state, CanvasKit-owned observations, and content construction without making those categories visually obvious.

Adding `interactionActivity: Binding<CanvasInteractionActivity>?` would be consistent with the existing output-binding pattern, but it would add another parameter whose apparent writability is broader than its intended authority.

## A possible first improvement: viewportOverlay

A focused first step is to expose consumer-owned viewport content:

```swift
CanvasView(...) {
  ArtworkView()
} viewportOverlay: {
  PreviewCharacterView()
}
```

The intended contract would be:

- `content` is artwork content in `CanvasSpace` and receives the artwork transform.
- `viewportOverlay` is fixed content in `ViewportSpace` and does not receive the artwork transform.
- Both closures inherit public CanvasKit Environment values such as `CanvasInteractionActivity`.
- The overlay is scoped to the canvas viewport rather than treated as application state.
- Decorative overlays can use `.allowsHitTesting(false)`; interactive overlays may intercept input over the area they occupy.

The exact stacking contract should be deliberate. A reasonable starting point would place consumer viewport content above the canvas interaction surface and below CanvasKit-owned tool UI. This permits interactive consumer controls while leaving the tool palette authoritative. Purely visual overlays remain responsible for disabling hit testing.

Wrappers such as GridKit's `GridCanvasView` would need to forward the viewport overlay builder explicitly. Otherwise the wrapper would recreate the same reachability boundary for its consumers.

The API should preserve the existing simple call site. One likely implementation shape is a generic `ViewportOverlay` view type, with the current initialiser retained as a convenience where `ViewportOverlay == EmptyView`, plus one overload accepting both builders. This keeps progressive disclosure: basic consumers still see a simple artwork closure, while consumers with fixed canvas-local UI opt into one clearly named additional scope.

## What viewportOverlay should not become

The viewport overlay should not be presented as a universal solution for state outside the artwork closure.

It does not help:

- menu commands or inspectors outside CanvasView;
- Paperbark's external trackpad input mapping;
- coordination between multiple canvases;
- app- or document-owned durable state;
- consumers that intentionally need to observe a canvas without rendering UI inside it.

Those cases still require explicit inputs or outward observation.

## A direction for clearer future APIs

CanvasKit can use the following taxonomy when new features are considered:

- **Configuration input:** Use a plain value when the caller configures CanvasKit and no ongoing synchronisation is needed.
- **Parent-owned mutable state:** Use a binding when the parent is a legitimate source of truth and may change the value.
- **CanvasKit-derived observation:** Prefer a clearly documented output mechanism when CanvasKit owns the value and external consumers only observe it. This might remain an output binding for API consistency, or evolve towards focused change callbacks or a deliberately read-only observation surface.
- **Canvas-local contextual state:** Publish a narrow Environment value for descendants in the artwork and viewport scopes.
- **Spatial composition:** Use clearly named builders when consumers need to place content in a semantic CanvasView layer.

Output APIs should remain focused enough that consumers interested in one value do not receive high-frequency changes from unrelated state. A single large writable “canvas session” value might appear convenient but could conflate ownership, widen mutation authority, and cause unnecessary observation. It should only be introduced if repeated consumer pressure demonstrates a coherent shared lifetime and contract.

Progressive disclosure is the desired experience:

```swift
CanvasView {
  ArtworkView()
}
```

should remain the normal entry point. More advanced capabilities should appear only when a consumer asks for them, through one additional spatial builder or focused modifiers rather than an intimidating all-purpose initialiser.

## Questions to ask for every new CanvasKit value

Before adding a public Environment value, binding, callback, model, or builder, ask:

1. Who creates and clears this value?
2. Who is allowed to change it?
3. Is it durable state, current activity, or retained history?
4. Where do its consumers live: outside CanvasView, fixed in the viewport, or inside the artwork?
5. Does the consumer need the complete value, or a narrower derived property?
6. Does it need to travel down the view tree, outward from CanvasView, or in both directions?
7. What should happen when CanvasView disappears or its artwork is replaced?
8. How frequently does it change, and which consumers should actually invalidate when it does?
9. Does a wrapper such as `GridCanvasView` need to forward the capability?
10. Can the common CanvasView call site remain simple and self-explanatory?

## Current working conclusions

- The three spatial scopes are a useful vocabulary for CanvasKit and its consumers.
- “Canvas-external or host” is intentionally broader and more accurate than “app-level”.
- Spatial scope, ownership, lifetime, and data-flow direction should be assessed separately.
- `CanvasInteractionActivity` belongs naturally in the CanvasView Environment for canvas-local consumers.
- A public `viewportOverlay` builder is a justified first improvement, with DrawString's preview as its strongest current motivating example.
- External observation remains necessary for genuine outside consumers such as Paperbark's trackpad integration.
- Existing bindings already represent more than one semantic direction, so future APIs should make ownership and authority clearer rather than merely accumulating optional parameters.
- CanvasKit should favour progressive disclosure: a small obvious default API, with focused capabilities available when a consumer's actual architecture requires them.
