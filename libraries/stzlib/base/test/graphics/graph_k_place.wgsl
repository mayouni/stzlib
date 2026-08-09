struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read> reach : array<u32>;
@group(0) @binding(2) var<storage, read_write> inst : array<f32>;
@group(0) @binding(3) var<storage, read> par : array<u32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let i = gid.x + tile.xoff * 64u;
  let n = par[0];  let w = par[1];  let perL = par[2];  let layers = par[3];
  if (i >= n) { return; }
  var c = 0u;
  for (var k = 0u; k < w; k = k + 1u) { c = c + countOneBits(reach[i * w + k]); }
  let impact = f32(c) - 1.0;
  let t = clamp(impact / f32(n) * 2.2, 0.0, 1.0);
  let layer = f32(i / perL);
  let slot  = f32(i % perL);
  let cols  = 24.0;
  let x = (layer - f32(layers) * 0.5) * 2.6;
  let y = floor(slot / cols) * 0.62 - 6.0;
  let z = ((slot % cols) - cols * 0.5) * 0.62;
  let s = 0.16 + 0.42 * t;
  let o = i * 36u;
  inst[o+0u]=s;   inst[o+1u]=0.0; inst[o+2u]=0.0; inst[o+3u]=0.0;
  inst[o+4u]=0.0; inst[o+5u]=s;   inst[o+6u]=0.0; inst[o+7u]=0.0;
  inst[o+8u]=0.0; inst[o+9u]=0.0; inst[o+10u]=s;  inst[o+11u]=0.0;
  inst[o+12u]=x;  inst[o+13u]=y;  inst[o+14u]=z;  inst[o+15u]=1.0;
  inst[o+16u]=1.0/s; inst[o+17u]=0.0;   inst[o+18u]=0.0;   inst[o+19u]=0.0;
  inst[o+20u]=0.0;   inst[o+21u]=1.0/s; inst[o+22u]=0.0;   inst[o+23u]=0.0;
  inst[o+24u]=0.0;   inst[o+25u]=0.0;   inst[o+26u]=1.0/s; inst[o+27u]=0.0;
  inst[o+28u]=0.0;   inst[o+29u]=0.0;   inst[o+30u]=0.0;   inst[o+31u]=1.0;
  inst[o+32u] = 0.16 + 0.80 * t;
  inst[o+33u] = 0.70 - 0.46 * t;
  inst[o+34u] = 0.52 - 0.28 * t;
  inst[o+35u] = 1.0;
}
