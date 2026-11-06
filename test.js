/* The only test that matters for the wasm: instantiate it, step it, and check
 * the frame it renders. Run with `node test.js`. */
const fs = require("fs");
const src = fs.readFileSync(`${__dirname}/particles.wasm`);
const W = 400, H = 225, PIX = W * H * 4;

const luma = (a) => {
  let s = 0;
  for (let i = 0; i < a.length; i += 4) s += a[i] + a[i + 1] + a[i + 2];
  return s;
};

WebAssembly.instantiate(src, {}).then(({ instance }) => {
  const ex = instance.exports;
  const need = ["fp", "np", "init", "set_mouse", "burst", "step", "memory"];
  const missing = need.filter((k) => !(k in ex));
  if (missing.length) throw new Error(`missing exports: ${missing}`);

  ex.init(12345);
  const buf = new Uint8ClampedArray(ex.memory.buffer, ex.fp(), PIX);
  if (buf.length !== PIX) throw new Error(`frame is ${buf.length} bytes, want ${PIX}`);
  if (ex.np() < 100) throw new Error("no particles");

  const start = luma(buf);
  ex.set_mouse(100, 100, 1);
  for (let i = 0; i < 90; i++) ex.step(1 / 60);
  const moved = luma(buf);
  if (moved === start) throw new Error("framebuffer never changed");
  for (let i = 3; i < buf.length; i += 4) if (buf[i] !== 255) throw new Error("alpha is not opaque");

  /* A burst redistributes the field, so total brightness is not the measure:
   * the frame has to visibly change where the impulse landed. */
  const before = Uint8Array.from(buf);
  ex.burst(200, 112);
  for (let i = 0; i < 20; i++) ex.step(1 / 60);
  let diff = 0;
  for (let i = 0; i < buf.length; i += 4) if (Math.abs(buf[i] - before[i]) > 8) diff++;
  if (diff < 2000) throw new Error(`burst moved only ${diff} pixels`);
  const postBurst = luma(buf);
  if (postBurst <= 0 || postBurst >= W * H * 765) throw new Error("frame is blank or fully blown out");

  /* Guards: a zero, negative, huge or NaN dt must not corrupt or throw. */
  ex.step(0);
  ex.step(-1);
  ex.step(1000);
  ex.step(NaN);
  ex.set_mouse(0, 0, 0);
  for (let i = 0; i < 30; i++) ex.step(1 / 60);

  console.log(`ok  ${src.length} bytes · ${ex.np()} particles · luma ${start} → ${moved} → ${postBurst}`);
}).catch((e) => {
  console.error("FAIL", e.message);
  process.exit(1);
});
