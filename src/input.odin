package main

import "core:fmt"
import "core:log"
import glm "core:math/linalg/glsl"
import sdl "vendor:sdl3"

InputKey :: enum {
	Up, // Q
	Right, // D
	Left, // A
	Down, // E
	Forward, // W
	Back, // S
}

MouseButton :: enum {
	Left,
	Middle,
	Right,
}

InputKeyState :: enum {
	None,
	Pressed,
	Held,
	Released,
}

KeysPressed: [InputKey]InputKeyState = {
	.Up      = .None,
	.Right   = .None,
	.Left    = .None,
	.Down    = .None,
	.Forward = .None,
	.Back    = .None,
}

MouseButtons: [MouseButton]InputKeyState = {
	.Left   = .None,
	.Middle = .None,
	.Right  = .None,
}

MouseState :: struct {
	position:     glm.vec2, // Current mouse position (screen coordinates)
	delta:        glm.vec2, // Movement since last frame (for camera rotation)
	scroll_delta: f32, // Mouse wheel scroll this frame
	is_captured:  bool, // Is mouse captured/locked to window?
}

Mouse: MouseState

// Maps InputKey to SDL Scancode
@(private = "file")
key_to_scancode := [InputKey]sdl.Scancode {
	.Up      = .E,
	.Right   = .D,
	.Left    = .A,
	.Down    = .Q,
	.Forward = .W,
	.Back    = .S,
}

// Maps MouseButton to SDL button ID
@(private = "file")
mouse_button_to_sdl := [MouseButton]u8 {
	.Left   = sdl.BUTTON_LEFT,
	.Middle = sdl.BUTTON_MIDDLE,
	.Right  = sdl.BUTTON_RIGHT,
}

// Call this every frame to update key and mouse states
input_update :: proc() {
	// Update keyboard state
	keyboard_state := sdl.GetKeyboardState(nil)

	for key in InputKey {
		scancode := key_to_scancode[key]
		is_down := keyboard_state[scancode]

		current_state := KeysPressed[key]

		// State transitions:
		// None -> Pressed (key just went down)
		// Pressed -> Held (key stayed down)
		// Held -> Held (key still down)
		// Any -> Released (key just went up)
		// Released -> None (key still up)

		if is_down {
			switch current_state {
			case .None, .Released:
				KeysPressed[key] = .Pressed
			case .Pressed, .Held:
				KeysPressed[key] = .Held
			}
		} else {
			switch current_state {
			case .Pressed, .Held:
				KeysPressed[key] = .Released
			case .Released, .None:
				KeysPressed[key] = .None
			}
		}
	}

	// todo make this a bit less senseless?
	// Update mouse position and delta
	mouse_state: sdl.MouseButtonFlags
	if Mouse.is_captured {
		// In relative mode, get relative motion directly
		_ = sdl.GetRelativeMouseState(&Mouse.delta.x, &Mouse.delta.y)
		mouse_state = sdl.GetMouseState(nil, nil)
		// Position doesn't matter in relative mode
	} else {
		// In normal mode, track position and calculate delta
		new_pos: glm.vec2
		mouse_state = sdl.GetMouseState(&new_pos.x, &new_pos.y)
		Mouse.delta = new_pos - Mouse.position
		Mouse.position = new_pos
	}

	// Update mouse button states (works in both modes)
	for button in MouseButton {
		sdl_button := mouse_button_to_sdl[button]
		// Check if button bit is set in the mouse state bitmask
		is_down: bool
		switch button {
		case .Left:
			is_down = (mouse_state & sdl.BUTTON_LMASK) != {}
		case .Middle:
			is_down = (mouse_state & sdl.BUTTON_MMASK) != {}
		case .Right:
			is_down = (mouse_state & sdl.BUTTON_RMASK) != {}
		}

		current_state := MouseButtons[button]

		if is_down {
			switch current_state {
			case .None, .Released:
				MouseButtons[button] = .Pressed
			case .Pressed, .Held:
				MouseButtons[button] = .Held
			}
		} else {
			switch current_state {
			case .Pressed, .Held:
				MouseButtons[button] = .Released
			case .Released, .None:
				MouseButtons[button] = .None
			}
		}
	}
}

// Helper functions for checking key states
input_is_key_pressed :: proc(key: InputKey) -> bool {
	return KeysPressed[key] == .Pressed
}

input_is_key_held :: proc(key: InputKey) -> bool {
	return KeysPressed[key] == .Held
}

input_is_key_down :: proc(key: InputKey) -> bool {
	return KeysPressed[key] == .Pressed || KeysPressed[key] == .Held
}

input_is_key_released :: proc(key: InputKey) -> bool {
	return KeysPressed[key] == .Released
}

// Helper functions for checking mouse button states
input_is_mouse_pressed :: proc(button: MouseButton) -> bool {
	return MouseButtons[button] == .Pressed
}

input_is_mouse_held :: proc(button: MouseButton) -> bool {
	return MouseButtons[button] == .Held
}

input_is_mouse_down :: proc(button: MouseButton) -> bool {
	return MouseButtons[button] == .Pressed || MouseButtons[button] == .Held
}

input_is_mouse_released :: proc(button: MouseButton) -> bool {
	return MouseButtons[button] == .Released
}

// Mouse utility functions
input_get_mouse_position :: proc() -> glm.vec2 {
	return Mouse.position
}

input_get_mouse_delta :: proc() -> glm.vec2 {
	return Mouse.delta
}

input_get_scroll_delta :: proc() -> f32 {
	return Mouse.scroll_delta
}

// Call this to capture/release the mouse (for FPS camera control)
input_set_mouse_captured :: proc(captured: bool) {
	Mouse.is_captured = captured
	if !sdl.SetWindowRelativeMouseMode(g.window, captured) {
		log.errorf("failed to set window relative mouse mode: %s\n", sdl.GetError())
		return
	}
	if captured {
		// Reset delta when capturing to avoid initial jump
		Mouse.delta = glm.vec2{0, 0}
	}
}

input_is_mouse_captured :: proc() -> bool {
	return Mouse.is_captured
}

// Call this to reset per-frame input states (scroll delta)
// Should be called at the start of event handling
input_begin_frame :: proc() {
	Mouse.scroll_delta = 0
}

// Call this from event handler when mouse wheel event occurs
input_handle_scroll :: proc(y: f32) {
	Mouse.scroll_delta += y // Accumulate in case of multiple scrolls per frame
}
