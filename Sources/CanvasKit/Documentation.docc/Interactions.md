
## Interactions

Thinking through interactions 

Input source
└─ Pointer
└─ Trackpad gesture
└─ Keyboard

↓ maps to

Intent
└─ Pan
└─ Select
└─ Draw
└─ Zoom

↓ applies to

State domain
└─ Viewport
└─ Document
└─ Selection



| Interaction         | Can coexist with  | Blocks              |
| ------------------- | ----------------- | ------------------- |
| Tap                 | Everything        | Nothing             |
| Hover               | Everything        | Nothing             |
| Pointer Drag (tool) | Gesture pan/zoom  | Other pointer drags |
| Two-finger Pan      | Pointer drag      | Nothing             |
| Pinch Zoom          | Pointer drag, pan | Nothing             |
| Rotate              | Pointer drag, pan | Nothing             |



These are not necessarily defined by the number of fingers.

PointerInteraction
- operates in content space
- usually single primary pointer
- absolute positions matter

GestureInteraction
- operates in view / world / mode space
- often multi-pointer
- relative motion matters
