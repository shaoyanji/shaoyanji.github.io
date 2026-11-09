/* site.js — load the wasm, hand it the pointer, blit one image per frame.
 *
 * The wasm owns everything visual: it simulates 1,800 points and writes an
 * RGBA frame into its own memory. This file never touches a pixel — it wraps
 * that memory in an ImageData (zero copy) and lets drawImage scale the 400x225
 * frame up to the viewport, where the GPU's bilinear filter does the bloom.
 */
(() => {
  const c = document.getElementById("field");
  if (!c || !window.WebAssembly) return;

  const W = 400, H = 225;
  const ctx = c.getContext("2d", { alpha: false });
  const small = document.createElement("canvas");
  small.width = W;
  small.height = H;
  const sctx = small.getContext("2d", { alpha: false });
  const still = matchMedia("(prefers-reduced-motion: reduce)");
  let ex, frame, dpr = 1, last = 0, img = null;

  const view = (w, h) => {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    c.width = Math.round(w * dpr);
    c.height = Math.round(h * dpr);
    c.style.width = w + "px";
    c.style.height = h + "px";
    ctx.imageSmoothingEnabled = true;
    ctx.imageSmoothingQuality = "high";
  };

  const draw = () => {
    sctx.putImageData(img, 0, 0);
    ctx.drawImage(small, 0, 0, c.width, c.height);
  };

  const tick = (t) => {
    frame = requestAnimationFrame(tick);
    const dt = last ? Math.min((t - last) / 1000, 0.05) : 1 / 60;
    last = t;
    ex.step(dt);
    draw();
  };

  WebAssembly.instantiateStreaming(fetch("particles.wasm"), {})
    .catch(() => fetch("particles.wasm").then((r) => r.arrayBuffer())
      .then((b) => WebAssembly.instantiate(b, {})))
    .then(({ instance }) => {
      ex = instance.exports;
      ex.init((Math.random() * 2 ** 31) | 0);
      img = new ImageData(new Uint8ClampedArray(ex.memory.buffer, ex.fp(), W * H * 4), W, H);
      view(innerWidth, innerHeight);
      draw();

      addEventListener("resize", () => {
        view(innerWidth, innerHeight);
        draw();
      });
      addEventListener("pointermove", (e) => {
        ex.set_mouse((e.clientX / innerWidth) * W, (e.clientY / innerHeight) * H, 1);
      }, { passive: true });
      addEventListener("pointerdown", (e) => {
        ex.burst((e.clientX / innerWidth) * W, (e.clientY / innerHeight) * H);
      }, { passive: true });
      addEventListener("pointerleave", () => ex.set_mouse(W / 2, H / 2, 0.12), { passive: true });
      document.addEventListener("visibilitychange", () => {
        if (document.hidden) {
          cancelAnimationFrame(frame);
          frame = 0;
        } else if (!frame && !still.matches) {
          last = 0;
          frame = requestAnimationFrame(tick);
        }
      });

      if (!still.matches) frame = requestAnimationFrame(tick);
      document.documentElement.dataset.field = "live";
    })
    .catch(() => {
      /* No wasm: the page is still a page. The CSS gradient is the backdrop. */
      document.documentElement.dataset.field = "off";
    });
})();
