#!/usr/bin/env bash
# Builds particles.wasm from src/particles.c.
#
# Needs clang with the wasm32 target and wasm-ld (the `lld` package). No
# emscripten, no SDK, no libc: the module has no imports at all, so the linker
# has nothing to resolve and the output is self-contained. `wasm-opt -Oz` runs
# when binaryen happens to be installed, shaving a few hundred bytes of
# function-name and section overhead.
set -euo pipefail
cd "$(dirname "$0")"

CC=${CC:-clang}

$CC \
  --target=wasm32 -std=c99 -Oz -flto -nostdlib -fno-builtin \
  -Wl,--no-entry -Wl,--strip-all \
  -Wl,--export=fp -Wl,--export=np -Wl,--export=init \
  -Wl,--export=set_mouse -Wl,--export=burst -Wl,--export=step \
  -o particles.wasm src/particles.c

if command -v wasm-opt >/dev/null 2>&1; then
  wasm-opt -Oz --strip-debug --strip-producers particles.wasm -o particles.wasm
fi

printf 'particles.wasm  %s bytes\n' "$(wc -c <particles.wasm)"
