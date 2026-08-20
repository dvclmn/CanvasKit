# Input Interactions

CanvasKit separates input source, interaction intent, and state mutation.

Input arrives as an ``Interaction``. Each interaction has an ``Interaction.Kind`` such as swipe, pinch, tap, drag, or hover. A tool can then declare the kinds it wants to handle with ``ToolCapability``.

## Default handling

CanvasKit provides defaults for viewport gestures:

- Swipe pans the viewport.
- Option-swipe zooms the viewport.
- Pinch zooms the viewport.
- Hover always updates the global pointer observation surface.

Tap and drag are tool-driven and are enabled only when the effective tool declares a matching capability. Hover capture is always enabled: a tool may claim hover for specialised resolution, but `onCanvasHover` still receives the mapped location and exit lifecycle independently of that tool result.

## Resolution flow

For each input event, CanvasKit builds an ``InteractionContext`` containing the interaction, phase, and active keyboard modifiers.

The resolver then:

1. Checks whether the effective tool has a matching capability.
2. Calls ``CanvasTool/resolveInteraction(context:currentTransform:)`` if the capability matches.
3. Applies the tool result, or falls through to CanvasKit defaults when the tool returns `.passthrough`.

This keeps default viewport navigation and observation available while still allowing tools to claim specific interactions.

## Public pointer lifecycles

`onCanvasHover` publishes ``CanvasHoverPhase/active(_:)`` for mapped pointer locations and exactly one ``CanvasHoverPhase/ended`` transition when the pointer exits.

`onCanvasDrag` publishes anchored marquee input as ``CanvasDragEvent``. ``CanvasDragEvent/start`` is the original anchor, ``CanvasDragEvent/current`` is the latest pointer location, and ``CanvasDragEvent/boundingRect`` is derived normalised geometry. The first accepted update is ``InteractionPhase/began``, later updates are ``InteractionPhase/changed``, normal release is ``InteractionPhase/ended``, and CanvasKit invalidation is ``InteractionPhase/cancelled``.

CanvasKit emits cancellation when an active drag recogniser is invalidated by a tool behaviour change or disablement, and clears active drag state when the view disappears. While the observing hierarchy remains mounted, every sequence that published an active update produces one `.ended` or `.cancelled` callback. SwiftUI's `DragGesture` does not expose a separate system-cancellation callback; an ordinary delivered `onEnded` remains `.ended`. Both terminal phases retain the last ordered endpoints, and terminal delivery observes the combined endpoints-and-phase snapshot, so an unchanged final location still produces the terminal callback.

Continuous Pan and Zoom drags mutate viewport transforms and do not publish `onCanvasDrag`; that public modifier describes anchored marquee input rather than frame-to-frame deltas.

## Coordinate spaces

Raw pointer input is captured in ``ViewportSpace``. CanvasKit maps pointer events into ``CanvasSpace`` using ``CoordinateSpaceMapper`` before publishing `onCanvasTap`, `onCanvasDrag`, and `onCanvasHover` callbacks.

## Standalone viewport input

Use ``SwiftUI/View/onViewportSwipe(requiredModifiers:isEnabled:perform:)`` or ``SwiftUI/View/onViewportPinch(isEnabled:perform:)`` when an app needs physical viewport input without adopting ``CanvasView`` or CanvasKit's transform policy.

``ViewportPinchEvent`` reports both start-relative ``ViewportPinchEvent/magnification`` and incremental ``ViewportPinchEvent/magnificationDelta``. The first recognised sample has an ``InteractionPhase/began`` phase, later samples use ``InteractionPhase/changed``, and the terminal sample uses ``InteractionPhase/ended``. CanvasKit does not report a cancelled phase because SwiftUI's `MagnifyGesture` does not distinguish cancellation in its public callbacks.

```swift
WaveformView()
  .onViewportPinch { event in
    lineWidth *= event.magnificationDelta
  }
```

This event route does not apply `zoomSensitivity`, clamp to `zoomRange`, or mutate a ``TransformState``. Use `onPinchGesture(zoom:isEnabled:)` when CanvasKit should own standard viewport zoom behaviour.
