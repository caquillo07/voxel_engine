package main

import "core:math"
import glm "core:math/linalg/glsl"


ScreenWidth :: 1280
ScreenHeight :: 720

BackgroundColor :: glm.vec4{0.1, 0.16, 0.25, 1.0}

WindowTitle :: "Voxels"

// camera
AspectRatio :: f32(ScreenWidth) / f32(ScreenHeight)
FovDeg: f32 : 50
VFov := glm.radians_f32(FovDeg) // vertical FOV
HFov := 2 * math.atan(math.tan(VFov * 0.5) * AspectRatio) // horizontal FOV
NearPlane :: 0.1
FarPlane :: 2000.0
PitchMax := glm.radians_f32(89)

// player
PlayerSpeed :: 5
PlayerRotSpeed :: 0.003
PlayerPos := glm.vec3{0, 0, 1}
MouseSensitivity :: 0.002
