# ``CanvasKit``

A SwiftUI canvas container for panning, zooming, coordinate mapping, and
tool-driven pointer interaction.

## Overview

CanvasKit wraps any SwiftUI view in an interactive viewport. The content remains
your artwork or document view; CanvasKit supplies the surrounding behaviour:
trackpad pan and pinch zoom, pointer tap/drag/hover capture, coordinate-space
mapping, and a small tool system for interpreting pointer input.

Use ``CanvasView`` directly for the simplest setup. Pass a
``TransformState`` binding when app or document state should own pan and zoom,
and pass a ``ToolConfiguration`` when you want to customise the available tools
or keyboard shortcuts.

## Topics

### Start Here

- <doc:UsingCanvasView>
- <doc:TransformStateOwnership>

### Interaction Model

- <doc:CanvasTools>
- <doc:PointerStyles>
- <doc:InputInteractions>
- <doc:ZoomBehaviour>

### Core API

- ``CanvasView``
- ``TransformState``
- ``CoordinateSpaceMapper``
- ``CanvasPointerStyle``

### Tools

- ``CanvasTool``
- ``CanvasToolID``
- ``ToolConfiguration``
- ``ToolSelection``
- ``ToolBinding``
- ``ToolCapability``
- ``InteractionContext``
- ``InteractionIntent``
- ``ToolResolution``

### Built-In Tools

- ``SelectTool``
- ``PanTool``
- ``ZoomTool``

### Events And Modifiers

- ``CanvasTapModifier``
- ``CanvasDragModifier``
- ``CanvasHoverModifier``
- ``CanvasDragEvent``
- ``CanvasHoverPhase``
- ``InteractionPhase``
- ``CanvasClipping``
- ``ViewportPinchEvent``
- ``ZoomRangeModifier``
- ``ZoomSensitivityModifier``
