# shaoyanji.github.io

The landing page: one screen, six places to read, and a particle field that
reacts to the pointer.

- `index.html`, `style.css` — the page. No frameworks, no fonts, no tracking.
- `src/particles.c` — the whole simulation and renderer, in wasm32.
- `site.js` — instantiates the module and blits one frame per animation frame.
- `build.sh` — clang → `particles.wasm` (~1.5 KB, no imports, no libc).
- `test.js` — instantiates the module in node and asserts the frame it renders.

## Why a wasm particle field

The effects are real simulation, not CSS keyframes: 1,800 points are attracted
and swirled by the pointer in C, drawn additively into a 400×225 RGBA buffer
that lives in the module's own memory. JavaScript never touches a pixel — it
wraps that buffer in an `ImageData` (zero copy) and `drawImage`s it up to the
viewport, where the GPU's bilinear filter supplies the bloom. The fade trail is
a right shift per channel, so there is no post-processing pass, no shader and no
texture upload. One frame costs about 0.3 ms of wasm.

The page works without it: if wasm fails to load, the CSS gradient is the
backdrop and the content is unchanged. `prefers-reduced-motion` renders a single
still frame and never starts the loop.

The page is also readable without the gradient: the `h1` sets its colour before
`background-clip:text`, so a browser that ignores the clip, or a forced-colors
mode, shows the name instead of none of it. The share card is
`assets/og.png`, drawn in the site's own palette, and `robots.txt` and
`sitemap.xml` are checked in because GitHub Pages generates neither.

## Build

```sh
clang --version          # any clang with the wasm32 target
bash build.sh            # writes particles.wasm (1486 bytes)
node test.js             # exercises init/step/burst against the frame
```

Under Nix, the `clang` from a `nix shell` is a cc-wrapper that injects
`-dynamic-linker`, which a `--target=wasm32 -nostdlib` link rejects. Use the
unwrapped compiler (`llvmPackages.clang-unwrapped`) with `lld` on `PATH`:

```sh
nix shell nixpkgs#llvmPackages.clang-unwrapped nixpkgs#lld \
  -c bash -c 'CC=$(command -v clang) bash build.sh && node test.js'
```

CI (`.github/workflows/static.yml`) builds, tests and deploys on every push to
`master`, so the served wasm always matches the C in this repo.
