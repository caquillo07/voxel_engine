package main

import "core:fmt"
import "core:log"
import glm "core:math/linalg/glsl"
import "core:strings"
import "core:time"

import gl "vendor:OpenGL"
import sdl "vendor:sdl3"

Game :: struct {
	isRunning:  bool,
	time:       time.Tick,
	deltaTime:  f64,
	window:     ^sdl.Window,
	quad:       QuadMesh,
	quadShader: Shader,
	camera:     Camera,
}

g: Game

main :: proc() {
	context.logger = log.create_console_logger()
	defer log.destroy_console_logger(context.logger)

	// TODO arena allocator for temp
	// TODO tracking allocator

	// Initialize SDL3 video subsystem
	if !sdl.Init({.VIDEO}) {
		log.panicf("Failed to initialize SDL3: %s", sdl.GetError())
	}
	defer sdl.Quit()

	g.window = sdl.CreateWindow(
		strings.clone_to_cstring(WindowTitle),
		ScreenWidth,
		ScreenHeight,
		{.HIGH_PIXEL_DENSITY, .RESIZABLE, .OPENGL},
	)
	if g.window == nil {
		log.panicf("failed to create window: %s", sdl.GetError())
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

	init_game()

	main_loop: for g.isRunning {
		g.deltaTime = time.duration_seconds(time.tick_since(g.time))
		g.time = time.tick_now()
		dt := f32(g.deltaTime)
		handle_events()
		update(dt)
		render(dt)

		free_all(context.temp_allocator)
	}
	log.infof("done!")
}

init_game :: proc() {
	quadShader, sok := load_shader("./shaders/quad.vert", "./shaders/quad.frag")
	if !sok {
		log.fatalf("failed to load shaders")
	}
	g.time = time.tick_now()
	g.isRunning = true
	g.camera = make_camera(PlayerPos, -90, 0)
	g.quadShader = quadShader
	g.quad = make_quad(quadShader)
	input_set_mouse_captured(true)
}

update :: proc(dt: f32) {
	windowTitle := strings.clone_to_cstring(
		fmt.tprintf("%s: FPS %.2f", WindowTitle, 1 / g.deltaTime),
		context.temp_allocator,
	)
	if !sdl.SetWindowTitle(g.window, windowTitle) {
		log.errorf("faiSDL_CaptureMouseled to set the window title")
	}

	// create the scene
	camera_update(&g.camera, dt)
	quad_update(&g.quad, dt)
}

render :: proc(dt: f32) {
	// matrix types in Odin are stored in column-major format but written as you'd normal write them
	gl.Viewport(0, 0, ScreenWidth, ScreenHeight)
	gl.ClearColor(BackgroundColor.r, BackgroundColor.g, BackgroundColor.b, BackgroundColor.a)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	quad_draw(g.quad)

	sdl.GL_SwapWindow(g.window)
}

handle_events :: proc() {
	input_begin_frame() // Reset per-frame states (scroll delta)

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

		case .MOUSE_WHEEL:
			input_handle_scroll(event.wheel.y)
		}
	}
	input_update() // Update keyboard and mouse states
}
