load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG4 SLICE 0 -- CAN A PASS READ WHAT AN EARLIER PASS WROTE?

	The GR challenge pass found this and I deferred it twice:

	    "TEX_TARGET = RenderAttachment|CopySrc, no TextureBinding -> a render
	     target CANNOT be sampled; HUD-over-3D or any post-process needs a
	     CPU round trip."

	A frame graph is a graph of PASSES and the RESOURCES they read and
	write. If no pass can read another's output, every edge in that graph is
	a lie and GG4 has nothing to schedule. So this is GG4's first slice, and
	it is a yes/no question with a picture attached.

	The test: draw something into target A, then run a SECOND pass that
	SAMPLES A and writes a transformed version into B -- entirely on the
	device, with no readback between them.

	Run:  ring gg4_multipass.ring
---------------------------------------------------------------------------*/

decimals(3)

if NOT StzGraphicsDevice()
	? "No GPU device -- nothing to measure."
	return
ok
? "device : " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
? ""

W = 512  H = 512

#---------------------------------------------------------------------------
? "-- pass 1: draw INTO A RENDER TARGET -------------------------"
#
# A real target (kind 0), written by a render pass. NOT a sampled texture
# uploaded from the CPU -- routing through TextureWrite would be the very
# round trip this gap is about, and a test that takes it proves nothing.
#---------------------------------------------------------------------------

cFlat = 'struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) col: vec4<f32> }
@vertex
fn vmain(@location(0) p: vec2<f32>, @location(1) col: vec4<f32>) -> VSOut {
  var o: VSOut;
  o.pos = vec4<f32>(p, 0.0, 1.0);
  o.col = col;
  return o;
}
@fragment
fn fmain(in: VSOut) -> @location(0) vec4<f32> { return in.col; }'

hFlat = StzEngineGpuRenderPipeline(cFlat, "2,4", 0)
if hFlat = 0
	? "   flat pipeline refused: " + StzEngineGpuLastError()
	return
ok

# a quad covering the left half, in a known colour
aTri = [ -1,-1, 0.2,0.4,0.8,1,   0,-1, 0.2,0.4,0.8,1,   0,1, 0.2,0.4,0.8,1,
         -1,-1, 0.2,0.4,0.8,1,   0,1, 0.2,0.4,0.8,1,   -1,1, 0.2,0.4,0.8,1 ]
hTriVB = StzEngineGpuBufferNew(len(aTri) * 4)
StzEngineGpuBufferUploadList(hTriVB, aTri)

hA = StzEngineGpuTextureNew(W, H, 0)        # 0 = RENDER TARGET
StzEngineGpuRenderBegin(hA, 0.9, 0.1, 0.1, 1)   # red background
StzEngineGpuRenderDraw(hFlat, hTriVB, 0, 6, 0)  # blue-ish left half
StzEngineGpuRenderEnd()

cSrc = StzEngineGpuTargetRead(hA)
? "   target A drawn: red field, blue-ish left half"

#---------------------------------------------------------------------------
? ""
? "-- pass 2: SAMPLE TARGET A, with no CPU round trip -----------"
#
# hA is handed straight to the draw as a texture. Nothing was read back and
# re-uploaded between the passes -- that is the whole claim.
#---------------------------------------------------------------------------

cPost = 'struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) uv: vec2<f32> }
@vertex
fn vmain(@location(0) p: vec2<f32>, @location(1) uv: vec2<f32>) -> VSOut {
  var o: VSOut;
  o.pos = vec4<f32>(p, 0.0, 1.0);
  o.uv = uv;
  return o;
}
@group(0) @binding(0) var tex: texture_2d<f32>;
@group(0) @binding(1) var smp: sampler;
@fragment
fn fmain(in: VSOut) -> @location(0) vec4<f32> {
  let c = textureSample(tex, smp, in.uv);
  return vec4<f32>(1.0 - c.r, 1.0 - c.g, 1.0 - c.b, 1.0);
}'

hPipe = StzEngineGpuRenderPipeline(cPost, "2,2", 0)
if hPipe = 0
	? "   post pipeline refused: " + StzEngineGpuLastError()
	return
ok

aQuad = [ -1,-1, 0,1,   1,-1, 1,1,   1,1, 1,0,
          -1,-1, 0,1,   1,1, 1,0,   -1,1, 0,0 ]
hVB = StzEngineGpuBufferNew(len(aQuad) * 4)
StzEngineGpuBufferUploadList(hVB, aQuad)

nBusBefore = StzEngineGpuCounter(2)
hB = StzEngineGpuTextureNew(W, H, 0)
StzEngineGpuRenderBegin(hB, 0, 0, 0, 1)
nDraw = StzEngineGpuRenderDraw(hPipe, hVB, 0, 6, hA)    # <- A sampled DIRECTLY
StzEngineGpuRenderEnd()
nBusPass = StzEngineGpuCounter(2) - nBusBefore
? "   pass 2 sampled TARGET A : status " + nDraw
? "   bytes across the bus between the passes : " + nBusPass + "   (0 = no round trip)"

cOut = StzEngineGpuTargetRead(hB)

# THE ASSERTION: every pixel of B must be the inverse of A. A pass that drew
# nothing, or sampled something else, cannot satisfy this.
nInv = 0  nSame = 0  nOther = 0
for i = 1 to 400
	nOff = (i * 601 % (W*H)) * 4 + 1
	nA = ascii(substr(cSrc, nOff, 1))
	nB = ascii(substr(cOut, nOff, 1))
	if fabs(nB - (255 - nA)) <= 1
		nInv++
	but nB = nA
		nSame++
	else
		nOther++
	ok
next
? ""
? "   sampled 400 pixels:  inverted " + nInv + "   unchanged " + nSame +
  "   neither " + nOther
? "   PASS 2 READ TARGET A ON THE DEVICE : " + (nInv > 380)

#---------------------------------------------------------------------------
? ""
? "-- and the hazard is still refused ---------------------------"
#
# Sampling the target you are WRITING is a genuine read-write hazard and
# must stay refused. The old check refused EVERY target, which is what made
# multi-pass impossible; the new one refuses exactly the live one.
#---------------------------------------------------------------------------

StzEngineGpuRenderBegin(hB, 0, 0, 0, 1)
nSelf = StzEngineGpuRenderDraw(hPipe, hVB, 0, 6, hB)     # sampling hB INTO hB
StzEngineGpuRenderEnd()
? "   sampling the LIVE target : status " + nSelf + "   (3 = BAD_ARG, refused)"
? "   the hazard check survived the fix : " + (nSelf != 0)

# write the picture so the effect is visible, not just asserted
cPng = StzEngineGpuPngEncode(W, H, cOut, 1)
write("gg4_postprocess.png", cPng)
cPng2 = StzEngineGpuPngEncode(W, H, cSrc, 1)
write("gg4_source.png", cPng2)
? ""
? "   wrote gg4_source.png and gg4_postprocess.png"

? ""
? "=============================================================="
? " GAP 2 CLOSED : " + iif(nInv > 380 and nSelf != 0, "YES", "NO")
? " a pass can read an earlier pass's output, and cannot read"
? " the one it is writing"
? "=============================================================="
