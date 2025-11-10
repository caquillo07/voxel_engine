package main

import "core:fmt"

import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"

QuadMesh :: struct {
	vbo:          u32,
	vao:          u32,
	// ebo:      u32,
	shader:       Shader,
	vertex_count: int,
	// vertices: []Vertex,
	// indices:  []u16,
}

// struct declaration
Vertex :: struct {
	pos: glm.vec3,
	col: glm.vec4,
}


make_quad :: proc(s: Shader) -> QuadMesh {
	vertices := []Vertex {
		{{0.5, 0.5, 0.0}, {0.0, 1.0, 0.0, 1.0}},
		{{-0.5, 0.5, 0.0}, {1.0, 0.0, 0.0, 1.0}},
		{{-0.5, -0.5, 0.0}, {1.0, 1.0, 0.0, 1.0}},
		{{0.5, 0.5, 0.0}, {0.0, 1.0, 0.0, 1.0}},
		{{-0.5, -0.5, 0.0}, {1.0, 1.0, 0.0, 1.0}},
		{{0.5, -0.5, 0.0}, {0.0, 0.0, 1.0, 1.0}},
	}
	m := QuadMesh {
		shader       = s,
		vertex_count = len(vertices),
	}
	gl.GenVertexArrays(1, &m.vao)
	gl.GenBuffers(1, &m.vbo)
	// gl.GenBuffers(1, &m.ebo)
	gl.BindVertexArray(m.vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, m.vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(vertices[0]),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), uintptr(offset_of(Vertex, pos)))
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 4, gl.FLOAT, false, size_of(Vertex), uintptr(offset_of(Vertex, col)))
	gl.EnableVertexAttribArray(1)

	// gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	// gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices)*size_of(indices[0]), raw_data(indices), gl.STATIC_DRAW)

	gl.BindVertexArray(0)
	vertices = nil
	return m
}

quad_update :: proc(m: ^QuadMesh, dt: f32) {
	shader_use(m.shader)
	shader_set_uniform_mat4(m.shader, "u_proj", g.camera.projMatrix)
	shader_set_uniform_mat4(m.shader, "u_view", g.camera.viewMatrix)
	shader_set_uniform_mat4(m.shader, "u_model", glm.identity(glm.mat4x4))
}

quad_unload :: proc(m: ^QuadMesh) {
	// gl.DeleteBuffers(1, &m.ebo)
	gl.DeleteBuffers(1, &m.vbo)
	gl.DeleteVertexArrays(1, &m.vao)
}

quad_draw :: proc(m: QuadMesh) {
	shader_use(m.shader)
	gl.BindVertexArray(m.vao)
	// gl.BindBuffer(gl.ARRAY_BUFFER, m.vbo)
	gl.DrawArrays(gl.TRIANGLES, 0, i32(m.vertex_count))
}
