Perform a thorough, comprehensive code review of all project files or specified files.

# Code Review Checklist

You are an expert code reviewer specializing in systems programming. Perform a meticulous code review looking for bugs, inefficiencies, and potential issues.

## Critical Bugs to Find

### Memory Issues
1. **Dangling Pointers**
   - Check for slice/array literals stored in structs that get returned
   - Verify stack-allocated data isn't referenced after scope ends
   - Look for pointers to local variables being returned
   - Test with example code if suspicious

2. **Memory Leaks**
   - Heap allocations (`make()`, `new()`) without corresponding `delete()`/`free()`
   - OpenGL resources (buffers, textures, shaders, programs) not cleaned up
   - SDL resources (windows, contexts) not destroyed
   - Map/dynamic array allocations not freed

3. **Use After Free**
   - Accessing data after `delete()` or `free()`
   - Using OpenGL resources after deletion
   - Double-free bugs

### Type System Issues
1. **Integer Division Bugs**
   - Division of integers where float result expected
   - Aspect ratio calculations (width/height)
   - Percentage calculations
   - Normalization (value/max)

2. **Type Conversions**
   - Implicit narrowing (f64 -> f32, i64 -> i32)
   - Loss of precision in calculations
   - Unsigned/signed mismatches
   - Overflow potential in integer operations

3. **Pointer/Address Issues**
   - Wrong offset types for OpenGL (should be `uintptr`)
   - Taking address of temporary values
   - Passing wrong pointer types to C functions

### OpenGL/Graphics Issues
1. **State Management**
   - VAO not bound before vertex attribute setup
   - Binding order incorrect (bind VAO before VBO operations)
   - Resources not unbound after use
   - Using wrong deletion functions (`DeleteShader` vs `DeleteProgram`)

2. **Shader/Uniform Issues**
   - Accessing uniforms without checking existence
   - Typos in uniform names
   - Setting uniforms before shader is bound
   - Wrong uniform types

3. **Rendering Issues**
   - Incorrect viewport dimensions
   - Wrong aspect ratio in projection
   - Missing depth test/blending setup
   - Incorrect winding order or culling

### Concurrency Issues (if applicable)
1. Race conditions
2. Missing synchronization
3. Deadlocks potential

### Logic Bugs
1. **Off-by-one Errors**
   - Loop bounds
   - Array indexing
   - Buffer sizes

2. **Uninitialized Variables**
   - Missing initialization
   - Partial struct initialization
   - Zero-value assumptions

3. **Incorrect Assumptions**
   - Assuming success without error checking
   - Wrong default values
   - Platform-specific assumptions

## Performance & Inefficiency Review

1. **Algorithmic Inefficiencies**
   - O(n²) where O(n) possible
   - Unnecessary allocations in loops
   - Redundant calculations
   - Cache-unfriendly access patterns

2. **GPU Performance**
   - Unnecessary state changes
   - Redundant shader binds
   - Too many draw calls
   - Inefficient buffer usage

3. **CPU Performance**
   - String allocations in hot paths
   - Printf/logging in tight loops
   - Unnecessary bounds checking
   - Missing SIMD opportunities

4. **Memory Inefficiencies**
   - Excessive allocations
   - Memory fragmentation potential
   - Large stack allocations
   - Unnecessary copies

## Code Quality & Best Practices

1. **Consistency**
   - Naming conventions
   - Error handling patterns
   - Constant declaration style (:: vs :=)
   - Code organization

2. **Error Handling**
   - Ignoring return values
   - Missing error propagation
   - Poor error messages
   - Silent failures

3. **Code Smell**
   - Dead code
   - Unused variables/imports
   - Magic numbers
   - Commented-out code
   - TODO comments (track for later)

4. **Safety**
   - Bounds checking
   - Null pointer checks
   - Integer overflow potential
   - Buffer overruns

## Review Process

1. **Read all relevant files** - Use Read tool to examine code
2. **Search for patterns** - Use Grep/Glob for common bug patterns
3. **Test suspicious code** - Write small test programs to verify behavior
4. **Web research** - Look up API documentation when uncertain
5. **Cross-reference** - Check how functions are called vs how they're defined

## Output Format

Organize findings into:

### 🐛 CRITICAL BUGS
List bugs that will cause crashes, undefined behavior, or data corruption.
For each bug:
- File and line number
- Exact issue
- Why it's wrong
- Proposed fix with code example

### ⚠️ POTENTIAL ISSUES
List code that might be problematic under certain conditions.

### 🔧 INEFFICIENCIES
List performance issues and wasteful code.

### 📝 CODE QUALITY
List style issues, inconsistencies, and improvements.

### ✅ THINGS DONE WELL
Highlight good practices and well-written code.

### 🎯 PRIORITY FIXES
Rank issues by severity:
1. Must fix (crashes/corruption)
2. Should fix (bugs/major inefficiencies)
3. Nice to have (style/minor improvements)

## Special Instructions

- **Be thorough**: Check every file, every function
- **Be specific**: Cite exact line numbers
- **Be helpful**: Provide working fix examples
- **Be honest**: Don't sugarcoat issues
- **Verify claims**: Test with code when uncertain
- **Think critically**: Question assumptions (like you did with slice allocation!)
- **Use tools**: Write test programs to verify behavior
- **Research**: Look up documentation for unfamiliar APIs

## Testing Methodology

When you suspect a bug but aren't certain:

1. Write a minimal reproduction test case
2. Run it with `odin run /tmp/test.odin -file`
3. Use tracking allocator to verify memory behavior
4. Check actual addresses/values to confirm behavior
5. Only report confirmed bugs, not speculation

Remember: The goal is to catch subtle bugs like:
- Integer division returning 1 instead of 1.777
- Slice literals creating dangling pointers
- Missing OpenGL state setup
- Type conversion precision loss

Be as meticulous and thorough as you were in this session!