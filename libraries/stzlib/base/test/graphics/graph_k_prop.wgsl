struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read> src : array<u32>;
@group(0) @binding(2) var<storage, read_write> dst : array<u32>;
@group(0) @binding(3) var<storage, read> off : array<u32>;
@group(0) @binding(4) var<storage, read> tgt : array<u32>;
@group(0) @binding(5) var<storage, read> par : array<u32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let i = gid.x + tile.xoff * 64u;
  let n = par[0];  let w = par[1];
  if (i >= n) { return; }
  let s = off[i];  let e = off[i + 1u];
  for (var k = 0u; k < w; k = k + 1u) {
    var acc = src[i * w + k];
    for (var q = s; q < e; q = q + 1u) { acc = acc | src[tgt[q] * w + k]; }
    dst[i * w + k] = acc;
  }
}
