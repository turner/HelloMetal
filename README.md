# HelloMetal

A Suite of 7 minimal Metal apps written in Swift 4.2. Highlights include:
- Multi-pass rendering
- Model I/O
- SceneKit
- OpenEXR
- Arcball (Gestural rotation widget based on Quaternions)
- A simple API layer that abstracts to 

HelloMetal is my attempt to write Metal apps in idomatic Swift. My goal is a suite of clear and approachable apps 
each illustrating a different aspect of Metal. Each app is a single view app. A model is rendered that can be rotated
using a finger gesture.

### Hello
A texture-mapped quad.

### HellCameraPlane
A texture-mapped quad rendered atop a background quad aligned with the camera far clipping plane

### HelloRenderPass
An example of two pass rendering
1. Render texture-mapped quad to a texture.
2. Texture-map the results of pass 1 atop a background quad aligned with the camera far clipping plane

### HelloModel_IO
Render a variety of Model I/O shapes - cube, sphere, etc.

### HelloLight
Similar to *HelloModel_IO* with a point light source positioned at the eye point

### HelloSceneKit

### HelloOpenEXR





