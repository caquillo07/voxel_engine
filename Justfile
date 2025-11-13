#!/usr/bin/env just --justfile

set shell := ["bash", "-cu"]

# Build flags (note: #+feature global-context must be in source files)
#ODIN_FLAGS := "-collection:deps=deps"
ODIN_FLAGS := ""

# Run voxel
run:
    odin run src/ -out:bin/voxel {{ODIN_FLAGS}}

# Build voxel binary
build:
    odin build src/ -out:bin/voxel {{ODIN_FLAGS}}

# Run with debug (tracking allocator enabled)
run-debug:
    odin run src/ -out:bin/voxel {{ODIN_FLAGS}} -debug

# Build with debug (tracking allocator enabled)
build-debug:
    odin build src/ -out:bin/voxel {{ODIN_FLAGS}} -debug

fmt:
    odinfmt src/ -w
