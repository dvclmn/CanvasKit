# Input Interactions

CanvasKit separates physical input, tool meaning, CanvasKit-owned mutation, and public observation. Keeping those stages distinct lets a tool consume input without inventing state, while viewport defaults and mapped callbacks remain predictable.

## Four questions for every interaction

An interaction passes through four independent decisions:

1. **Capture:** Is a recogniser installed for this interaction kind?
2. **Routing:** Does the effective tool have a matching ``ToolCapability``?
3. **Resolution:** Does the tool consume the interaction, request an ``InteractionAdjustment``, or yield to a CanvasKit default?
4. **Observation:** Does CanvasKit publish a mapped callback independently of that adjustment?

“Global” therefore does not mean “tools never see this interaction.” It means CanvasKit keeps capture, a default, or public observation available independently of the selected tool.

| Interaction | Capture policy | Tool routing | CanvasKit default | Public observation |
| --- | --- | --- | --- | --- |
| Swipe | Always installed | Matching tool gets first refusal | Pan; Option-swipe zooms | Standalone `onViewportSwipe` is a separate API |
| Pinch | Always installed | Matching tool gets first refusal | Zoom | Standalone `onViewportPinch` is a separate API |
| Rotation | Resolution model exists; `CanvasView` capture is not yet wired | Matching tool gets first refusal when supplied programmatically | Rotate | None |
| Hover | Always installed | Matching tool gets first refusal | No state adjustment | Always publishes `onCanvasHover` |
| Tap | Installed when the effective tool declares tap | Required modifiers must match | None | Published when the tool requests a tap pointer adjustment |
| Drag | Installed when the effective tool declares drag | Required modifiers must match | None | Accepted marquee drags publish `onCanvasDrag`; continuous drags do not |

## Capability and intent resolution

``Interaction`` describes what physically happened. ``ToolCapability`` describes what an effective tool is willing to resolve, including required modifiers and an ``InteractionIntent``. CanvasKit attaches the selected capability to ``InteractionContext/matchedCapability`` before calling ``CanvasTool/resolveInteraction(context:currentTransform:)``, making ``InteractionContext/intent`` the resolved semantic meaning for that callback.

Required modifiers use subset matching. A capability requiring Option also matches Option+Shift. When several capabilities match the same interaction, CanvasKit chooses the capability requiring the greatest number of modifiers; declaration order is the tie-breaker.

```swift
var inputCapabilities: [ToolCapability] {
  [
    ToolCapability(interaction: .drag, intent: .pan),
    ToolCapability(interaction: .drag, intent: .zoom, modifiers: [.option]),
    ToolCapability(
      interaction: .drag,
      intent: .drawMarquee,
      modifiers: [.option, .shift]
    ),
  ]
}
```

With Option+Shift held, the third capability wins. With only Option held, the second wins. With neither held, the first wins.

> Important: A drag’s matched capability and intent are established when CanvasKit first accepts the gesture and remain stable until that drag ends. Current modifiers still update in the context, so a tool may provide dynamic feedback, but modifier changes do not silently reinterpret an in-progress drag as a different capability.

## Tool resolution

For each accepted input update, CanvasKit:

1. Builds an ``InteractionContext`` from the physical interaction, phase, and modifiers.
2. Selects and attaches the effective tool’s best matching capability.
3. Calls ``CanvasTool/resolveInteraction(context:currentTransform:)`` when a capability matched.
4. Applies a returned pointer or transform adjustment.
5. Falls through to CanvasKit’s default only when the tool returns ``ToolResolution/passthrough`` or no capability matched a global interaction.
6. Records any independently observable pointer event.

Use ``ToolResolution/consumed`` when the tool claims an interaction without requesting CanvasKit-owned mutation. Select’s marquee drag is the canonical example: the tool consumes the drag, while `CanvasHandler` independently retains the ordered marquee snapshot for `onCanvasDrag`.

Use `.handled(...)` when the tool requests a transform or pointer adjustment. Use ``ToolResolution/passthrough`` when CanvasKit should continue to a viewport default.

## Drag representations

Drag data has three forms with separate responsibilities:

- ``PointerDragPayload`` is the immediate viewport-space recogniser payload. Continuous tools receive frame deltas; marquee tools receive ordered anchor/current points.
- `PointerDragSnapshot` is CanvasKit’s internal retained marquee event. It combines ordered points with lifecycle phase.
- ``CanvasDragEvent`` is the public snapshot after both points have been mapped independently into ``CanvasSpace``.

``CanvasDragEvent/start`` remains the original anchor and ``CanvasDragEvent/current`` remains the latest pointer location, including for reverse-direction drags. ``CanvasDragEvent/boundingRect`` is derived normalised geometry rather than the source of truth.

## Public pointer lifecycles

`onCanvasHover` publishes ``CanvasHoverPhase/active(_:)`` for mapped pointer locations and exactly one ``CanvasHoverPhase/ended`` transition when the pointer exits.

`onCanvasDrag` publishes anchored marquee input as ``CanvasDragEvent``. The first accepted update is ``InteractionPhase/began``, later updates are ``InteractionPhase/changed``, normal release is ``InteractionPhase/ended``, and CanvasKit invalidation is ``InteractionPhase/cancelled``.

CanvasKit emits cancellation when an active drag recogniser is invalidated by a tool behaviour change or disablement, and clears active drag state when the view disappears. SwiftUI’s `DragGesture` does not expose a separate system-cancellation callback; an ordinary delivered `onEnded` remains `.ended`. Both terminal phases retain the last ordered endpoints, so an unchanged final location still produces a distinct terminal event.

Continuous Pan and Zoom drags mutate viewport transforms and do not publish `onCanvasDrag`; that public modifier describes anchored marquee input rather than frame-to-frame deltas.

## Latest event versus active state

The latest event and current activity answer different questions. CanvasKit retains terminal drag snapshots so observers receive `.ended` or `.cancelled`; it separately removes that interaction kind from active state. A retained terminal event must not be cleared merely because the interaction is no longer active.

## Coordinate spaces

Raw pointer input is captured in ``ViewportSpace``. CanvasKit maps pointer observations into ``CanvasSpace`` using ``CoordinateSpaceMapper`` before publishing `onCanvasTap`, `onCanvasDrag`, and `onCanvasHover` callbacks.

## Standalone viewport input

Use ``SwiftUI/View/onViewportSwipe(requiredModifiers:isEnabled:perform:)`` or ``SwiftUI/View/onViewportPinch(isEnabled:perform:)`` when an app needs physical viewport input without adopting ``CanvasView`` or CanvasKit’s transform policy.

``ViewportPinchEvent`` reports both start-relative ``ViewportPinchEvent/magnification`` and incremental ``ViewportPinchEvent/magnificationDelta``. The first recognised sample has an ``InteractionPhase/began`` phase, later samples use ``InteractionPhase/changed``, and the terminal sample uses ``InteractionPhase/ended``. CanvasKit does not report a cancelled phase because SwiftUI’s `MagnifyGesture` does not distinguish cancellation in its public callbacks.

```swift
WaveformView()
  .onViewportPinch { event in
    lineWidth *= event.magnificationDelta
  }
```

This event route does not apply `zoomSensitivity`, clamp to `zoomRange`, or mutate a ``TransformState``. Use `onPinchGesture(zoom:isEnabled:)` when CanvasKit should own standard viewport zoom behaviour.
