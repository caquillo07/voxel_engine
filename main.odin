package main

import "core:fmt"
import "core:log"
import glm "core:math/linalg/glsl"
import "core:strings"
import "core:time"

import gl "vendor:OpenGL"
import sdl "vendor:sdl3"

Vec2 :: [2]f32
Vec3 :: [3]f32
Vec4 :: [4]f32

Width :: 1280
Height :: 720

BackgroundColor :: Vec4{0.1, 0.16, 0.25, 1.0}

WindowTitle :: "Voxels"

Game :: struct {
	isRunning: bool,
	time:      time.Tick,
	deltaTime: f64,
	window:    ^sdl.Window,
}

g: Game

main :: proc() {
	context.logger = log.create_console_logger()
	defer log.destroy_console_logger(context.logger)
	init_game()

	// Initialize SDL3 video subsystem
	if !sdl.Init({.VIDEO}) {
		log.panicf("Failed to initialize SDL3: %s", sdl.GetError())
	}
	defer sdl.Quit()

	g.window = sdl.CreateWindow(
		strings.clone_to_cstring(WindowTitle),
		Width,
		Height,
		{.HIGH_PIXEL_DENSITY, .RESIZABLE, .OPENGL},
	)
	if g.window == nil {
		fmt.printfln("failed to create window")
		return
	}
	defer sdl.DestroyWindow(g.window)

	sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, 3)
	sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, 3)
	sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK, cast(i32)sdl.GLProfileFlag.CORE)
	sdl.GL_SetAttribute(.DEPTH_SIZE, 24)

	if !sdl.GL_MakeCurrent(g.window, sdl.GL_CreateContext(g.window)) {
		log.panicf("failed to make openGL context")
	}
	gl.load_up_to(3, 3, sdl.gl_set_proc_address)
	gl.Enable(gl.DEPTH_TEST | gl.CULL_FACE | gl.BLEND)

	main_loop: for g.isRunning {
		handle_events()
		update()
		render()

		free_all(context.temp_allocator)
	}
	log.infof("done!")
}

init_game :: proc() {
	g = {
		time      = time.tick_now(),
		isRunning = true,
	}
}

update :: proc() {
	g.deltaTime = time.duration_seconds(time.tick_since(g.time))
	g.time = time.tick_now()
	windowTitle := strings.clone_to_cstring(
		fmt.tprintf("%s: FPS %.2f", WindowTitle, 1 / g.deltaTime),
		context.temp_allocator,
	)
	if !sdl.SetWindowTitle(g.window, windowTitle) {
		log.errorf("failed to set the window title")
	}
}

render :: proc() {
	gl.Viewport(0, 0, Width, Height)
	gl.ClearColor(BackgroundColor.r, BackgroundColor.g, BackgroundColor.b, BackgroundColor.a)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	sdl.GL_SwapWindow(g.window)
}

handle_events :: proc() {
	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			log.info("Window close requested")
			g.isRunning = false

		case .KEY_DOWN:
			if event.key.key == sdl.K_ESCAPE {
				log.info("Escape pressed, closing window")
				g.isRunning = false
			}
		}
	}
}
