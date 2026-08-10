load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG4 SLICE 1 -- COMPUTE AND RENDER IN ONE SUBMIT

	The second gap the GR challenge pass found:

	    "stz_gpu_dispatch submits per call -> compute+render cannot share a
	     submit (2/frame measured), though GR0's spike PROVED one submit
	     works. ~60us/frame avoidable."

	GR0 proved the hardware and the API allow it; the product path never
	adopted it. A frame graph EXECUTES a schedule, and a schedule that pays
	a submit per node is not a schedule, it is a list.

	THE WITNESS IS THE SUBMIT COUNTER. Not the wall clock -- a submit saved
	is not necessarily a millisecond saved, and counting the thing that
	changed is honest where timing a shared machine is not.

	The scene: a compute kernel WRITES VERTICES, a render pass DRAWS them.
	That is the composition GR0 witnessed, now on the product path.

	Run:  ring gg4_oneframe.ring
---------------------------------------------------------------------------*/

decimals(3)

if NOT StzGraphicsDevice()
	? "No GPU device -- nothing to measure."
	return
ok
? "device : " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
? ""

W = 400  H = 400
NTRI = 64

# a kernel that writes a fan of triangles into a VERTEX buffer
cGen = 'struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read_write> verts : array<f32>;
@group(0) @binding(2) var<storage, read> par : array<f32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let i = gid.x + tile.xoff * 64u;
  let n = u32(par[0]);
  let phase = par[1];
  if (i >= n) { return; }
  let a0 = 6.2831853 * f32(i) / f32(n) + phase;
  let a1 = 6.2831853 * f32(i + 1u) / f32(n) + phase;
  let b = i * 18u;                       // 3 verts * (2 pos + 4 col)
  // centre
  verts[b + 0u] = 0.0;  verts[b + 1u] = 0.0;
  verts[b + 2u] = 0.15; verts[b + 3u] = 0.18; verts[b + 4u] = 0.35; verts[b + 5u] = 1.0;
  // rim 1
  verts[b + 6u] = cos(a0) * 0.9;  verts[b + 7u] = sin(a0) * 0.9;
  verts[b + 8u] = 0.9; verts[b + 9u] = 0.65; verts[b + 10u] = 0.2; verts[b + 11u] = 1.0;
  // rim 2
  verts[b + 12u] = cos(a1) * 0.9; verts[b + 13u] = sin(a1) * 0.9;
  verts[b + 14u] = 0.2; verts[b + 15u] = 0.75; verts[b + 16u] = 0.6; verts[b + 17u] = 1.0;
}'

hGen = StzEngineGpuKernelCompile(cGen)
if hGen = 0
	? "kernel refused: " + StzEngineGpuLastError()
	return
ok

cDraw = 'struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) col: vec4<f32> }
@vertex
fn vmain(@location(0) p: vec2<f32>, @location(1) col: vec4<f32>) -> VSOut {
  var o: VSOut;
  o.pos = vec4<f32>(p, 0.0, 1.0);
  o.col = col;
  return o;
}
@fragment
fn fmain(in: VSOut) -> @location(0) vec4<f32> { return in.col; }'

hPipe = StzEngineGpuRenderPipeline(cDraw, "2,4", 0)
hVerts = StzEngineGpuBufferNew(NTRI * 18 * 4)
hPar = StzEngineGpuBufferNew(16)
hTarget = StzEngineGpuTextureNew(W, H, 0)

#---------------------------------------------------------------------------
? "-- the OLD way: dispatch submits, then the pass submits ------"
#---------------------------------------------------------------------------

StzEngineGpuBufferUploadList(hPar, [ NTRI, 0.0, 0, 0 ])
StzEngineGpuCountersReset()
StzEngineGpuDispatch(hGen, [ hVerts, hPar ], ceil(NTRI / 64), 1)
StzEngineGpuRenderBegin(hTarget, 0.04, 0.05, 0.09, 1)
StzEngineGpuRenderDraw(hPipe, hVerts, 0, NTRI * 3, 0)
StzEngineGpuRenderEnd()
StzEngineGpuSync()
nSubmitsOld = StzEngineGpuCounter(6)
cOld = StzEngineGpuTargetRead(hTarget)
? "   submits for compute + render : " + nSubmitsOld

#---------------------------------------------------------------------------
? ""
? "-- the NEW way: one frame, one submit ------------------------"
#---------------------------------------------------------------------------

StzEngineGpuBufferUploadList(hPar, [ NTRI, 0.0, 0, 0 ])
StzEngineGpuCountersReset()
StzEngineGpuFrameBegin()
? "   frame active : " + StzEngineGpuFrameActive()
StzEngineGpuDispatch(hGen, [ hVerts, hPar ], ceil(NTRI / 64), 1)
StzEngineGpuRenderBegin(hTarget, 0.04, 0.05, 0.09, 1)
StzEngineGpuRenderDraw(hPipe, hVerts, 0, NTRI * 3, 0)
StzEngineGpuRenderEnd()
nMid = StzEngineGpuCounter(6)
? "   submits BEFORE FrameEnd : " + nMid + "   (nothing has gone yet)"
StzEngineGpuFrameEnd()
StzEngineGpuSync()
nSubmitsNew = StzEngineGpuCounter(6)
cNew = StzEngineGpuTargetRead(hTarget)
? "   submits for the SAME work : " + nSubmitsNew

#---------------------------------------------------------------------------
? ""
? "-- and the picture must be IDENTICAL -------------------------"
#
# Fewer submits is only progress if the same pixels come out. A frame that
# batched the work and dropped some of it would look like a win.
#---------------------------------------------------------------------------

nDiff = 0
nL = len(cOld)
for i = 1 to nL step 997
	if substr(cOld, i, 1) != substr(cNew, i, 1)
		nDiff++
	ok
next
? "   sampled " + floor(nL / 997) + " bytes, differing : " + nDiff
? "   same picture, fewer submits : " + (nDiff = 0)

# it actually DREW something -- an all-clear target would also "match"
nInk = 0
for i = 1 to nL step 401
	if ascii(substr(cNew, i, 1)) > 30
		nInk++
	ok
next
? "   and the target is not empty : " + (nInk > 100) + "   (" + nInk + " lit samples)"

cPng = StzEngineGpuPngEncode(W, H, cNew, 1)
write("gg4_oneframe.png", cPng)
? "   wrote gg4_oneframe.png"

#---------------------------------------------------------------------------
? ""
? "-- a frame with MANY passes still costs one submit -----------"
#---------------------------------------------------------------------------

StzEngineGpuCountersReset()
StzEngineGpuFrameBegin()
for k = 1 to 6
	StzEngineGpuBufferUploadList(hPar, [ NTRI, k * 0.3, 0, 0 ])
	StzEngineGpuDispatch(hGen, [ hVerts, hPar ], ceil(NTRI / 64), 1)
	StzEngineGpuRenderBegin(hTarget, 0.04, 0.05, 0.09, 1)
	StzEngineGpuRenderDraw(hPipe, hVerts, 0, NTRI * 3, 0)
	StzEngineGpuRenderEnd()
next
StzEngineGpuFrameEnd()
StzEngineGpuSync()
nMany = StzEngineGpuCounter(6)
? "   6 compute passes + 6 render passes : " + nMany + " submit(s)"
? "   (the old way would have cost 12)"

? ""
? "=============================================================="
? " GAP 3 CLOSED : " + iif(nSubmitsNew < nSubmitsOld and nDiff = 0, "YES", "NO")
? " compute + render : " + nSubmitsOld + " submits -> " + nSubmitsNew
? " twelve passes    : " + nMany + " submit"
? "=============================================================="
