struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read_write> reach : array<u32>;
@group(0) @binding(2) var<storage, read> par : array<u32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let i = gid.x + tile.xoff * 64u;
  let n = par[0];  let w = par[1];
  if (i >= n) { return; }
  reach[i * w + (i / 32u)] = reach[i * w + (i / 32u)] | (1u << (i % 32u));
}
