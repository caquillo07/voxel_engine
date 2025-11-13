package main

import "core:fmt"
import "core:log"
import os2 "core:os/os2"
import "core:strings"
import "core:time"
import gl "vendor:OpenGL"
import sdl "vendor:sdl3"

Game :: struct {
	isRunning:           bool,
	time:                time.Tick,
	deltaTime:           f64,
	window:              ^sdl.Window,
	quad:                QuadMesh,
	quadShader:          Shader,
	camera:              Camera,
	title_update_timer:  f64,
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

	// Load OpenGL library
	if !sdl.GL_LoadLibrary(nil) {
		log.warnf("Failed to load OpenGL library: %s", sdl.GetError())
	}

	// Set OpenGL attributes before creating window - match working C version exactly
	sdl.GL_SetAttribute(.ACCELERATED_VISUAL, 1)
	sdl.GL_SetAttribute(.DOUBLEBUFFER, 1)
	sdl.GL_SetAttribute(.DEPTH_SIZE, 24)
	sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK, transmute(i32)sdl.GL_CONTEXT_PROFILE_CORE)
    sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, 4)
    sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, 1)
	when ODIN_OS == .Darwin {
		sdl.GL_SetAttribute(.CONTEXT_FLAGS, transmute(i32)sdl.GL_CONTEXT_FORWARD_COMPATIBLE_FLAG)
	}

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

	gl_context := sdl.GL_CreateContext(g.window)
	if gl_context == nil {
		log.panicf("failed to create openGL context: %s", sdl.GetError())
	}

	if !sdl.GL_MakeCurrent(g.window, gl_context) {
		log.panicf("failed to make openGL context current: %s", sdl.GetError())
	}

	gl.load_up_to(4, 1, sdl.gl_set_proc_address)

	// Log OpenGL info for debugging
	log.infof("OpenGL Version: %s", gl.GetString(gl.VERSION))
	log.infof("OpenGL Vendor: %s", gl.GetString(gl.VENDOR))
	log.infof("OpenGL Renderer: %s", gl.GetString(gl.RENDERER))
	log.infof("GLSL Version: %s", gl.GetString(gl.SHADING_LANGUAGE_VERSION))

	// Enable OpenGL features separately (not with bitwise OR)
	gl.Enable(gl.DEPTH_TEST)
	gl.Enable(gl.CULL_FACE)
	gl.Enable(gl.BLEND)

	// Enable VSync (1 = sync with display refresh rate, 0 = no vsync)
	if !sdl.GL_SetSwapInterval(1) {
		log.warnf("Failed to enable VSync: %s", sdl.GetError())
	}

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
		log.panicf("failed to load shaders")
	}
	g.time = time.tick_now()
	g.isRunning = true
	g.camera = make_camera(PlayerPos, -90, 0)
	g.quadShader = quadShader
	g.quad = make_quad(quadShader)
	input_set_mouse_captured(true)
}

update :: proc(dt: f32) {
	// Update window title every 0.25 seconds (4 times per second)
	TITLE_UPDATE_INTERVAL :: 0.25
	g.title_update_timer += g.deltaTime
	if g.title_update_timer >= TITLE_UPDATE_INTERVAL {
		g.title_update_timer = 0
		windowTitle := strings.clone_to_cstring(
			fmt.tprintf("%s: FPS %.2f", WindowTitle, 1 / g.deltaTime),
			context.temp_allocator,
		)
		if !sdl.SetWindowTitle(g.window, windowTitle) {
			log.errorf("failed to set the window title")
		}
	}

	// create the scene
	camera_update(&g.camera, dt)
	quad_update(&g.quad, dt)
}

render :: proc(dt: f32) {
	// Get actual framebuffer size (handles Retina/HiDPI displays)
	drawable_width, drawable_height: i32
	sdl.GetWindowSizeInPixels(g.window, &drawable_width, &drawable_height)

	// matrix types in Odin are stored in column-major format but written as you'd normal write them
	gl.Viewport(0, 0, drawable_width, drawable_height)
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

