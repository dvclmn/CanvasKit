# Input Interactions

CanvasKit separates input source, interaction intent, and state mutation.

Input arrives as an ``Interaction``. Each interaction has an
``Interaction.Kind`` such as swipe, pinch, tap, drag, or hover. A tool can then
declare the kinds it wants to handle with ``ToolCapability``.

## Default handling

CanvasKit provides defaults for viewport gestures:

- Swipe pans the viewport.
- Option-swipe zooms the viewport.
- Pinch zooms the viewport.

Pointer events are tool-driven. Tap, drag, and hover are enabled only when the
effective tool declares a matching capability.

## Resolution flow

For each input event, CanvasKit builds an ``InteractionContext`` containing the
interaction, phase, and active keyboard modifiers.

The resolver then:

1. Checks whether the effective tool has a matching capability.
2. Calls ``CanvasTool/resolveInteraction(context:currentTransform:)`` if the
   capability matches.
3. Applies the tool result, or falls through to CanvasKit defaults when the tool
   returns `.passthrough`.

This keeps default viewport navigation available while still allowing tools to
claim specific interactions.

## Coordinate spaces

Raw pointer input is captured in ``ViewportSpace``. CanvasKit maps pointer
events into ``CanvasSpace`` using ``CoordinateSpaceMapper`` before publishing
`onCanvasTap`, `onCanvasDrag`, and `onCanvasHover` callbacks.
