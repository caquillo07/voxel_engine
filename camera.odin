package main

import "core:fmt"
import "core:math"
import glm "core:math/linalg/glsl"

Camera :: struct {
	pos:        glm.vec3,
	yaw:        f32,
	pitch:      f32,
	up:         glm.vec3,
	right:      glm.vec3,
	forward:    glm.vec3,
	projMatrix: glm.mat4x4,
	viewMatrix: glm.mat4x4,
}

make_camera :: proc(pos: glm.vec3, yaw, pitch: f32) -> Camera {
	return Camera {
		pos = pos,
		yaw = math.to_radians_f32(yaw),
		pitch = math.to_radians_f32(pitch),
		up = glm.vec3{0, 1, 0},
		right = glm.vec3{1, 0, 0},
		forward = glm.vec3{0, 0, -1},
		projMatrix = glm.mat4Perspective(VFov, AspectRatio, NearPlane, FarPlane),
		viewMatrix = glm.identity(glm.mat4x4),
	}
}

camera_update :: proc(c: ^Camera, dt: f32) {
	// camera inputs
	// update keyboard controls
	vel := PlayerSpeed * dt
	if input_is_key_down(.Forward) {
		camera_move_forward(c, vel)
	}
	if input_is_key_down(.Back) {
		camera_move_back(c, vel)
	}
	if input_is_key_down(.Right) {
		camera_move_right(c, vel)
	}
	if input_is_key_down(.Left) {
		camera_move_left(c, vel)
	}
	if input_is_key_down(.Up) {
		camera_move_up(c, vel)
	}
	if input_is_key_down(.Down) {
		camera_move_down(c, vel)
	}

	// update mouse controls
	if input_is_mouse_captured() {
		dx := input_get_mouse_delta()
		camera_rotate_yaw(c, dx.x * MouseSensitivity)
		camera_rotate_pitch(c, dx.y * MouseSensitivity)
	}

	// camera update
	// update vectors
	c.forward.x = glm.cos(c.yaw) * glm.cos(c.pitch)
	c.forward.y = glm.sin(c.pitch)
	c.forward.z = glm.sin(c.yaw) * glm.cos(c.pitch)

	c.forward = glm.normalize(c.forward)
	c.right = glm.normalize(glm.cross(c.forward, glm.vec3{0, 1, 0}))
	c.up = glm.normalize(glm.cross(c.right, c.forward))

	// update view matrix
	c.viewMatrix = glm.mat4LookAt(c.pos, c.pos + c.forward, c.up)
}

camera_rotate_pitch :: proc(c: ^Camera, deltaY: f32) {
	c.pitch -= deltaY
	c.pitch = glm.clamp(c.pitch, -PitchMax, PitchMax)
}

camera_rotate_yaw :: proc(c: ^Camera, deltaX: f32) {
	c.yaw += deltaX
}

camera_move_left :: proc(c: ^Camera, velocity: f32) {
	c.pos -= c.right * velocity
}

camera_move_right :: proc(c: ^Camera, velocity: f32) {
	c.pos += c.right * velocity
}

camera_move_up :: proc(c: ^Camera, velocity: f32) {
	c.pos += c.up * velocity
}

camera_move_down :: proc(c: ^Camera, velocity: f32) {
	c.pos -= c.up * velocity
}

camera_move_forward :: proc(c: ^Camera, velocity: f32) {
	c.pos += c.forward * velocity
}

camera_move_back :: proc(c: ^Camera, velocity: f32) {
	c.pos -= c.forward * velocity
}
