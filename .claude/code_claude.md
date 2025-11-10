# Project Instructions for Claude Code

## Project: Voxel Engine Tech Demo

### What We're Building
A Minecraft-style voxel engine tech demo in Odin, showcasing:
- Chunk-based terrain generation
- Block breaking and placing
- Textures
- Lighting
- Water rendering

**Not building:** Multiplayer, mobs, complex game mechanics - this is a rendering/engine demo.

### Technical Specifications

**Graphics Stack:**
- OpenGL 3.3 Core (widely compatible, mature)
- SDL3 for windowing and input
- Resolution: 1280x720 (16:9 aspect ratio)
- GLM (Odin core:math/linalg/glsl) for math

**World Structure:**
- Chunk-based terrain system
- Chunk size: TBD (likely 16x16x256, standard Minecraft dimensions)
- Meshing strategy: TBD (will implement when needed)
- Culling strategy: TBD (frustum culling minimum, occlusion TBD)

**Performance Targets:**
- **Minimum:** 120 FPS on integrated graphics
- **Target:** 240 FPS (nice to have)
- **Priority:** Make it work first, then make it fast
- Profile before optimizing - measure, don't guess

**Asset Pipeline:**
- Voxels only (no complex models)
- Texture system: TBD (atlas vs array textures - decide when implementing)
- Keeping it simple - this is a demo

**Architecture Style:**
- ECS-ish approach with fat entity structs
- Functions as systems operating on structs
- Start simple (grug style), add complexity only when pain demands it
- No premature abstraction

### Current Status

**Completed:**
- ✅ Window creation with OpenGL 3.3 context
- ✅ Shader loading and uniform system
- ✅ FPS camera with WASD + Q/E movement
- ✅ Mouse look with capture mode
- ✅ Input system (keyboard state polling + mouse)
- ✅ Basic rendering (test quad with vertex colors)
- ✅ MVP matrix pipeline working

**Next Steps (TBD - implement when needed):**
- Chunk data structure
- Block type system
- Terrain generation
- Chunk meshing
- Texturing
- Lighting
- Water rendering

### Design Decisions

**Decided:**
- Language: Odin (explicit, simple, fast)
- Graphics API: OpenGL 3.3 Core (compatibility + simplicity)
- Window/Input: SDL3 (battle-tested, simple API)
- Camera: FPS style with mouse capture
- Input: State polling (not event-based) for movement
- Time: f64 for accumulation, f32 for per-frame delta

**TBD (decide when implementing):**
- Exact chunk size
- Meshing algorithm (naive, greedy, or other)
- Texture organization (atlas, array, or bindless)
- Lighting model (simple ambient + directional? vertex lighting?)
- Water rendering technique
- Chunk loading/unloading strategy
- Memory allocation strategy (arena allocators, pools, etc.)

**Explicitly NOT doing:**
- Complex abstractions upfront
- Generic systems "for the future"
- Multiplayer/networking
- Advanced graphics techniques (PBR, post-processing, etc.) unless needed
- Complex entity/component systems until pain demands it

---

## Development Philosophy: Grug Brain Developer

**Follow the wisdom of https://grugbrain.dev/ - think like grug, code like grug.**

### Core Grug Principles

**complexity very, very bad**
- grug say: simple good, complex bad
- if solution seem too clever, probably bad
- grug no like fancy abstraction, grug like code that grug understand in morning

**say same thing twice ok, say same thing 100 time bad**
- small duplication better than bad abstraction
- copy-paste sometimes ok if keep code simple
- only abstract when pain of duplication worse than complexity of abstraction

**grug no like type system make grug jump through hoop**
- type should help grug, not fight grug
- if spend more time satisfy type checker than solve problem, types too complex
- Odin type system good - grug like explicit, grug no like magic

**test good, test catch bug before grug go home for day**
- write test when code seem scary
- write test when find bug (like dangling pointer!)
- test better than clever, test sleep well at night

**refactor: grug only refactor when need feature, not before**
- no refactor "just in case"
- no refactor "for future"
- wait until pain real, then make better

**grug no like rewrite from scratch**
- rewrite almost always bad idea
- fix one thing at time
- small change good, big change bad

**premature optimization: grug say NO**
- make work first
- make work correct
- THEN make fast if need
- most time, simple code plenty fast

### Applying Grug to This Project

**When writing code:**
1. **Simple first**: Write obvious solution, not clever solution
2. **Test suspicious code**: If code feel dangerous (like slice in struct), write test
3. **Explicit over implicit**: Rather see `f32(width) / f32(height)` than mysterious type inference
4. **One thing at a time**: Fix aspect ratio bug, test, commit. Then do next thing.
5. **No speculation**: Don't add feature for "maybe later". Add when need.

**When reviewing code:**
1. If grug need think hard to understand code, code too complex
2. If need write comment explain code, maybe code should be simpler
3. Magic number bad, named constant good (grug remember `AspectRatio`, not `1.777`)

**When debugging:**
1. Write small test, see what actually happen (not what grug think happen)
2. Use print statement, use debugger, use tracking allocator
3. Fix bug, write test so bug no come back
4. One bug at time

**When adding features:**
1. What simplest thing that work?
2. Do that thing
3. Test that thing
4. Ship that thing
5. Only then think about next thing

**Grug wisdom applied to issues we found:**

- **Integer division bug**: grug see `width / height` give wrong number. grug add `f32()`. simple fix. good.
- **Dangling pointer**: grug feel suspicious. grug write test. test show bad. grug fix. now grug sleep well.
- **Shader uniform check**: grug get crash from typo in uniform name. grug add helper that warn. now grug see typo before crash. good.

### Anti-Patterns (Grug No Like)

❌ "Let's make this super generic to handle all future cases"
- grug say: solve problem in front of grug today

❌ "I'll add these 10 helper functions we might need"
- grug say: add when need, not before

❌ "Let me refactor this to be more elegant"
- grug say: does it work? yes? then leave alone until have reason change

❌ "I'll add comprehensive error handling for every edge case"
- grug say: handle errors that actually happen, not errors that grug imagine

❌ "Let's use latest fancy technique from paper"
- grug say: boring technology work good for 20 year, fancy technique maybe work 2 week

### When Complexity Actually Needed

Sometimes complexity necessary (grug sad, but grug accept):
- OpenGL state management (grug no can change, must learn)
- 3D math (quaternion complex, but simpler than alternative)
- Memory management (must do right, or game crash)

When complexity necessary:
1. Hide in small, well-tested module
2. Write good comment explain why complex
3. Write test that prove work
4. No let complexity leak into rest of codebase

### Grug-Approved Workflow

```
1. grug have problem
2. grug think: what simple solution?
3. grug write simple solution
4. grug test solution
5. solution work? good! grug done.
6. solution no work? grug fix, go back step 4
7. solution work but slow? grug measure first, then optimize what actually slow
8. grug ship code, grug happy
```

### Remember

**grug brain developer not stupid, grug brain developer wise**

grug been writing code many year. grug see many fancy thing come and go. grug see simple code still work after 10 year. grug see complex clever code break after 10 day.

grug choose simple.

---

## Project-Specific Guidelines

### Memory Management (Very Important!)
- Stack-allocated slice literals (`[]Type{...}`) only live during current scope
- Don't store stack slices in returned structs - dangling pointer!
- Heap allocate with `make()` if need to keep data
- Always `delete()` what you `make()`
- Use tracking allocator in debug builds to catch leaks

### OpenGL State
- Always bind VAO before setting up vertex attributes
- Unbind (bind 0) when done to prevent accidents
- Delete resources in reverse order of creation
- Use `DeleteProgram` for shaders, not `DeleteShader`

### Type Safety
- Cast integers to float for division when float result needed
- Be explicit: `f32(a) / f32(b)` better than hoping for float promotion
- Use `uintptr` for OpenGL offsets

### Code Style
- Simple functions better than clever one-liners
- Named constants better than magic numbers
- Clear variable names better than short clever names
- If need comment to explain, maybe code should be clearer

### Testing Philosophy
- When suspicious, write test
- Test program better than guessing
- Use tracking allocator to verify memory assumptions
- Small focused tests better than big comprehensive tests

---

## Project-Specific Conventions

### File Organization
```
main.odin        - Entry point, game loop, global game state
camera.odin      - FPS camera system
input.odin       - Keyboard and mouse state polling
shader.odin      - Shader loading and uniform helpers
constants.odin   - Global constants (screen size, FOV, speeds, etc.)
quad.odin        - Test mesh (will be replaced/generalized later)
shaders/         - GLSL shader files
```

**When adding new systems:**
- One file per system (chunk.odin, terrain.odin, block.odin, etc.)
- Keep files focused and small
- Don't split prematurely - one file fine until it gets unwieldy

### Naming Conventions
```odin
// Types: PascalCase
Camera :: struct { ... }
ChunkMesh :: struct { ... }

// Constants: PascalCase or SCREAMING_SNAKE_CASE for true constants
ScreenWidth :: 1280
MAX_CHUNKS :: 1024

// Functions: snake_case with type prefix
camera_update :: proc(c: ^Camera, dt: f32)
chunk_generate :: proc(pos: ChunkPos) -> Chunk

// Variables: snake_case
player_pos: glm.vec3
chunk_mesh: ChunkMesh

// Globals: snake_case with 'g' prefix (minimize these!)
g: Game  // Global game state
```

### Module Patterns
```odin
// System with state (like Camera, Chunk)
Thing :: struct {
    // ... state ...
}

make_thing :: proc(...) -> Thing { }      // Constructor
thing_update :: proc(t: ^Thing, dt: f32) // Update system
thing_render :: proc(t: Thing)            // Render system
thing_destroy :: proc(t: ^Thing)          // Cleanup

// Pure utility (like math helpers)
calculate_thing :: proc(x, y: f32) -> f32 { }
```

### Performance Guidelines

**Measurement first:**
- Use Odin's profiler when optimizing
- Measure FPS with actual voxel data, not just test quad
- Don't optimize before profiling (grug say: premature optimization bad!)

**Known performance patterns:**
- Batch OpenGL calls (fewer draw calls better)
- Minimize state changes (shader swaps, texture binds expensive)
- Frustum culling mandatory for acceptable performance
- Consider greedy meshing only after basic rendering works

**Memory allocation:**
- Minimize allocations in game loop
- Consider arena allocator for per-frame temp allocations
- Profile memory with tracking allocator
- Keep chunk data cache-friendly (TBD exact layout when implementing)

**Graphics performance:**
- Assume integrated graphics = limited bandwidth
- Keep vertex data small
- Batch by texture to minimize binds
- Cull aggressively (frustum minimum, occlusion if needed)

### Testing Strategy

**When to write tests:**
- Chunk meshing algorithm (complex, easy to break)
- Terrain generation (need reproducible results)
- Frustum culling math (easy to get wrong)
- Any code that feels scary

**What NOT to test:**
- Simple getters/setters
- Obvious glue code
- Graphics code (test by looking at screen)
- Until it's actually complex enough to break

**How to test:**
- Small focused tests in /tmp/test_*.odin
- Use tracking allocator to verify no leaks
- Visual tests for rendering (easiest to run game and look)

---

*grug say: write code that make future-you happy when debug at 2am*
*simple code make future-you say "thank you past-me"*
*clever code make future-you say "what past-me thinking???"*

**be kind to future-you. write simple code.**

---

## Common Patterns & Snippets

### Checking for OpenGL errors (debug builds)
```odin
when ODIN_DEBUG {
    check_gl_error :: proc(location: string) {
        err := gl.GetError()
        if err != gl.NO_ERROR {
            log.errorf("OpenGL error at %s: %d", location, err)
        }
    }
}
```

### Chunk position/block position conversions (for later)
```odin
// Will implement when needed - placeholder for common pattern
block_to_chunk_pos :: proc(block_pos: [3]i32) -> [3]i32
chunk_to_world_pos :: proc(chunk_pos: [3]i32) -> glm.vec3
```

### Safe shader uniform setting (already implemented)
```odin
// Always check return value for critical uniforms
if !shader_set_uniform_mat4(shader, "u_proj", proj) {
    log.error("Failed to set projection matrix!")
}

// Or use or_return for cleaner code
shader_set_uniform_mat4(shader, "u_proj", proj) or_return
```

### Frame timing pattern (already in use)
```odin
main_loop: for g.isRunning {
    g.deltaTime = time.duration_seconds(time.tick_since(g.time))
    g.time = time.tick_now()
    dt := f32(g.deltaTime)  // Convert to f32 for game logic

    handle_events()
    update(dt)
    render(dt)

    free_all(context.temp_allocator)  // Clear temp allocations
}
```
