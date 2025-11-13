package main

import "core:fmt"
import "core:log"
import glm "core:math/linalg/glsl"
import "core:os/os2"
import gl "vendor:OpenGL"

Shader :: struct {
	id:       u32,
	uniforms: gl.Uniforms,
}

load_shader :: proc(vertex_path, fragment_path: string) -> (s: Shader, ok: bool) {
	s.id = gl.load_shaders_file(vertex_path, fragment_path) or_return
	log.infof("loaded %s and %s\n", vertex_path, fragment_path)
	s.uniforms = gl.get_uniforms_from_program(s.id)
	return s, true
}

unload_shader :: proc(s: Shader) {
	gl.DeleteProgram(s.id)
	gl.destroy_uniforms(s.uniforms)
}

shader_use :: proc(s: Shader) {
	gl.UseProgram(s.id)
}

// Helper to get uniform location with error checking
// Returns false and logs warning if uniform not found
shader_get_uniform :: proc(s: Shader, name: string) -> (uniform: gl.Uniform_Info, ok: bool) {
	uniform, ok = s.uniforms[name]
	if !ok {
		log.warnf("Uniform '%s' not found in shader program %d", name, s.id)
	}
	return
}

// Scalar uniforms
shader_set_uniform_f32 :: proc(s: Shader, name: string, v: f32) -> bool {
	uniform := shader_get_uniform(s, name) or_return
	v := v
	gl.Uniform1fv(uniform.location, 1, &v)
	return true
}

shader_set_uniform_i32 :: proc(s: Shader, name: string, v: i32) -> bool {
	uniform := shader_get_uniform(s, name) or_return
	v := v
	gl.Uniform1iv(uniform.location, 1, &v)
	return true
}

shader_set_uniform_bool :: proc(s: Shader, name: string, v: bool) -> bool {
	uniform := shader_get_uniform(s, name) or_return
	value := i32(v ? 1 : 0)
	gl.Uniform1iv(uniform.location, 1, &value)
	return true
}

// Vector uniforms
shader_set_uniform_vec2 :: proc(s: Shader, name: string, v: glm.vec2) -> bool {
	uniform := shader_get_uniform(s, name) or_return
	v := v
	gl.Uniform2fv(uniform.location, 1, &v[0])
	return true
}

shader_set_uniform_vec3 :: proc(s: Shader, name: string, v: glm.vec3) -> bool {
	uniform := shader_get_uniform(s, name) or_return
	v := v
	gl.Uniform3fv(uniform.location, 1, &v[0])
	return true
}

shader_set_uniform_vec4 :: proc(s: Shader, name: string, v: glm.vec4) -> bool {
	uniform := shader_get_uniform(s, name) or_return
	v := v
	gl.Uniform4fv(uniform.location, 1, &v[0])
	return true
}

// Matrix uniforms
shader_set_uniform_mat3 :: proc(s: Shader, name: string, m: glm.mat3) -> bool {
	uniform := shader_get_uniform(s, name) or_return
	m := m
	gl.UniformMatrix3fv(uniform.location, 1, false, &m[0, 0])
	return true
}

shader_set_uniform_mat4 :: proc(s: Shader, name: string, m: glm.mat4) -> bool {
	uniform := shader_get_uniform(s, name) or_return
	m := m
	gl.UniformMatrix4fv(uniform.location, 1, false, &m[0, 0])
	return true
}

// Texture/sampler uniforms
shader_set_uniform_texture :: proc(s: Shader, name: string, texture_unit: i32) -> bool {
	uniform := shader_get_uniform(s, name) or_return
	texture_unit := texture_unit
	gl.Uniform1iv(uniform.location, 1, &texture_unit)
	return true
}
