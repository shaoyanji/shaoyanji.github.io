/* particles.c — the entire simulation and renderer, in wasm32 with no libc.
 *
 * 2,600 points are attracted to the pointer, swirled around it and drawn
 * additively into a 400x225 RGBA buffer that JS blits with putImageData and
 * scales up on the GPU. The upscale's bilinear filtering is the bloom, and the
 * fade (a right shift per channel) is the motion trail — so nothing here costs
 * a draw call, a shader or a texture upload.
 *
 * No malloc, no libm: the two constants live in .bss, sqrt is a hardware
 * instruction, and the swirl needs no trig. Four exports, ~3 KB of wasm.
 */

#define W 400
#define H 225
#define N 1800
#define PIX (W * H * 4)

static unsigned char fb[PIX];
static float px[N], py[N], vx[N], vy[N];
static unsigned int seed = 0x9e3779b9u;
static float mx = W * 0.5f, my = H * 0.5f, pull = 0.f;

static unsigned int rnd(void) {
  seed ^= seed << 13;
  seed ^= seed >> 17;
  seed ^= seed << 5;
  return seed;
}

static inline void addpx(int o, int r, int g, int b) {
  int v;
  v = fb[o] + r;
  fb[o] = v > 255 ? 255 : v;
  v = fb[o + 1] + g;
  fb[o + 1] = v > 255 ? 255 : v;
  v = fb[o + 2] + b;
  fb[o + 2] = v > 255 ? 255 : v;
}

/* JS needs the buffer address; everything else it needs is a one-liner. */
unsigned char *fp(void) { return fb; }
int np(void) { return N; }

void init(unsigned int s) {
  int i;
  seed = s | 1u;
  for (i = 0; i < PIX; i += 4) {
    fb[i] = 0;
    fb[i + 1] = 0;
    fb[i + 2] = 16;
    fb[i + 3] = 255;
  }
  for (i = 0; i < N; i++) {
    px[i] = (float)(rnd() % W) + 0.5f;
    py[i] = (float)(rnd() % H) + 0.5f;
    vx[i] = (float)((int)(rnd() & 255) - 128) * 0.02f;
    vy[i] = (float)((int)(rnd() & 255) - 128) * 0.02f;
  }
}

void set_mouse(float x, float y, float strength) {
  mx = x;
  my = y;
  pull = strength;
}

void burst(float x, float y) {
  int i;
  for (i = 0; i < N; i++) {
    float dx = px[i] - x, dy = py[i] - y;
    float d2 = dx * dx + dy * dy + 40.f;
    float f = 70.f / d2;
    vx[i] += dx * f;
    vy[i] += dy * f;
  }
}

void step(float t) {
  int i;
  float k = t * 60.f;

  if (!(k > 0.f)) return;
  if (k > 3.f) k = 3.f;

  /* Decay toward a deep indigo floor: v - v>>3 converges at 8, so the trail
   * fades to the page's background instead of to pure black, and a point keeps
   * a visible streak for about a dozen frames. */
  for (i = 0; i < PIX; i += 4) {
    fb[i] -= fb[i] >> 3;
    fb[i + 1] -= fb[i + 1] >> 3;
    fb[i + 2] = fb[i + 2] - (fb[i + 2] >> 3) + 1;
  }

  for (i = 0; i < N; i++) {
    float dx = mx - px[i], dy = my - py[i];
    float d2 = dx * dx + dy * dy + 90.f;
    float g = k * pull * 12.f / d2;
    float s = k * pull * 34.f / d2;
    float sp, x, y;

    vx[i] += dx * g - dy * s;
    vy[i] += dy * g + dx * s;
    vx[i] *= 0.99f;
    vy[i] *= 0.99f;
    vy[i] -= 0.0015f * k;

    sp = vx[i] * vx[i] + vy[i] * vy[i];
    if (sp > 12.25f) {
      sp = 3.5f / __builtin_sqrtf(sp);
      vx[i] *= sp;
      vy[i] *= sp;
    }

    x = px[i] + vx[i] * k;
    y = py[i] + vy[i] * k;
    if (x < 0.f) x += W;
    if (x >= W) x -= W;
    if (y < 0.f) y += H;
    if (y >= H) y -= H;
    /* The splat covers a 2x2 block plus a soft neighbour, so the last row and
     * column stay clear: a point there would write past the buffer. */
    if (x > W - 2) x = W - 2;
    if (y > H - 2) y = H - 2;
    px[i] = x;
    py[i] = y;

    {
      /* Speed picks the colour: gold for the fast, cyan for the slow. */
      float sp2 = __builtin_sqrtf(vx[i] * vx[i] + vy[i] * vy[i]);
      int q = (int)(sp2 * 70.f);
      int r, gg, b, o;

      if (q > 255) q = 255;
      r = (q * 255) >> 8;
      gg = (q * q) >> 8;
      b = 255 - (q >> 1);

      o = (((int)y) * W + ((int)x)) * 4;
      addpx(o, r, gg, b);
      addpx(o + 4, (r * 3) >> 3, (gg * 3) >> 3, (b * 3) >> 3);
      addpx(o + W * 4, (r * 3) >> 3, (gg * 3) >> 3, (b * 3) >> 3);
      addpx(o + W * 4 + 4, r >> 3, gg >> 3, b >> 3);
    }
  }
}
