
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
