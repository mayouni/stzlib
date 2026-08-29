load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG4 -- THE FRAME GRAPH

	Passes and the resources they read and write, declared. The ORDER, the
	resource LIFETIMES and the memory ALIASING are all derived; none of them
	is written by hand.

	KILL CRITERION, written in the plan before any of this existed:

	    "if the scheduler cannot beat the hand-ordered passes we already
	     write, it is ceremony; keep the manual order and ship only the RULE
	     checks, which are valuable on their own."

	So this file has to answer a question that can come back NO. The thing
	the scheduler has to beat hand-ordering by is MEMORY: a hand-written
	frame gives every resource its own target, because tracking which ones
	could share is exactly the bookkeeping nobody keeps right.

	Run:  ring gg4_framegraph.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " GG4 -- passes and resources as a graph"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. The order is DERIVED, not declared ---------------------"
#
# The passes are added in a deliberately WRONG order. If the schedule came
# from the declaration, composite would run first and draw nothing.
#---------------------------------------------------------------------------

oFG = new stzFrameGraph(512, 512)
oFG.AddPass(:Composite, [ :Reads = [ :scene, :blurred ], :Writes = [ :screen ] ])
oFG.AddPass(:Blur,      [ :Reads = [ :scene ],           :Writes = [ :blurred ] ])
oFG.AddPass(:Scene,     [ :Writes = [ :scene ] ])
oFG.Compile()

aOrd = oFG.Order()
? "   declared : Composite, Blur, Scene"
? "   DERIVED  : " + @@(aOrd)
# A :Symbol IS lowercase -- Ring folds them -- so a pass declared :Scene is
# named "scene" and comparing against "Scene" fails while the ORDER is
# perfectly correct. Compare case-insensitively, the way the class itself
# resolves pass names.
chk("Scene runs first", StzLower(aOrd[1]) = "scene")
chk("Composite runs last", StzLower(aOrd[3]) = "composite")
chk("Blur sits between them", StzLower(aOrd[2]) = "blur")

#---------------------------------------------------------------------------
? ""
? "-- 2. The kill criterion: does it BEAT hand-ordering? --------"
#
# A hand-written frame allocates one target per resource. The graph knows
# when each resource stops being needed, so two that never overlap share
# one. That is the difference, and it is a number.
#---------------------------------------------------------------------------

? "   logical resources : " + oFG.ResourceCount()
? "   physical targets  : " + oFG.PhysicalTargets()
? "   saved             : " + oFG.TargetsSaved()
aL = oFG.Lifetimes()
_aA19_ = aL
_nA19_ = len(_aA19_)
for _iA19_ = 1 to _nA19_
	a = _aA19_[_iA19_]
	? "     " + PadR(a[1], 9) + " live from step " + a[2] + " to " + a[3]
next
# HONEST: this frame saves NOTHING, and that is the right answer. scene,
# blurred and screen are ALL live at the composite step, so no two of them
# can share a target. A scheduler that claimed a saving here would be lying.
chkeq("a frame where everything feeds the composite saves nothing",
      oFG.TargetsSaved(), 0)
? "   (correct: all three are live at the composite, so none can share)" 

# a deeper chain: the saving should GROW, because more resources die early
oD = new stzFrameGraph(512, 512)
oD.AddPass(:P1, [ :Writes = [ :r1 ] ])
oD.AddPass(:P2, [ :Reads = [ :r1 ], :Writes = [ :r2 ] ])
oD.AddPass(:P3, [ :Reads = [ :r2 ], :Writes = [ :r3 ] ])
oD.AddPass(:P4, [ :Reads = [ :r3 ], :Writes = [ :r4 ] ])
oD.AddPass(:P5, [ :Reads = [ :r4 ], :Writes = [ :screen ] ])
oD.Compile()
? ""
? "   a 5-pass chain: " + oD.ResourceCount() + " resources -> " +
  oD.PhysicalTargets() + " targets  (saved " + oD.TargetsSaved() + ")"
chk("a longer chain saves MORE", oD.TargetsSaved() > oFG.TargetsSaved())

nBytes = oD.TargetsSaved() * 512 * 512 * 4
? "   at 512x512 RGBA that is " + nBytes + " bytes of VRAM not allocated"

#---------------------------------------------------------------------------
? ""
? "-- 3. The proofs, in the house finding shape -----------------"
#
# A frame graph that only ORDERS is half a tool. These go into
# stzRuleReport, the same gate that judges code rules and security rules.
#---------------------------------------------------------------------------

chk("a sound frame reports sound", oFG.IsSound())
chkeq("and has no findings", len(oFG.Findings()), 0)

# a CYCLE: two passes each reading what the other writes
oC = new stzFrameGraph(256, 256)
oC.AddPass(:A, [ :Reads = [ :fromB ], :Writes = [ :fromA ] ])
oC.AddPass(:B, [ :Reads = [ :fromA ], :Writes = [ :fromB ] ])
oC.Compile()
chk("a CYCLE is detected", NOT oC.IsSound())
? "   cycle finding : " + oC.Findings()[1][5]

# READ-BEFORE-WRITE: a pass reads something nobody writes
oHole = new stzFrameGraph(256, 256)
oHole.AddPass(:Only, [ :Reads = [ :ghost ], :Writes = [ :screen ] ])
oHole.Compile()
chk("reading an unwritten resource is an ERROR", NOT oHole.IsSound())
? "   hole finding  : " + oHole.Findings()[1][5]

# DEAD WORK: written, never read
oW = new stzFrameGraph(256, 256)
oW.AddPass(:Make,  [ :Writes = [ :used, :wasted ] ])
oW.AddPass(:Use,   [ :Reads = [ :used ], :Writes = [ :screen ] ])
oW.Compile()
chk("dead work is reported (as a warning, not an error)", oW.IsSound())
chk("  ...and it is actually reported", len(oW.Findings()) = 1)
? "   dead finding  : " + oW.Findings()[1][5]

# it reaches the SHARED gate
oRep = oC.Report()
chk("the findings reach stzRuleReport", isObject(oRep))

#---------------------------------------------------------------------------
? ""
? "-- 4. Refusals name themselves ------------------------------"
#---------------------------------------------------------------------------

chk("a pass declared twice is refused", Raises('
	o = new stzFrameGraph(64, 64)
	o.AddPass(:X, [ :Writes = [ :a ] ])
	o.AddPass(:X, [ :Writes = [ :b ] ])
'))
chk("a pass with no reads and no writes is refused", Raises('
	o = new stzFrameGraph(64, 64)
	o.AddPass(:X, [])
'))
chk("asking before Compile is refused", Raises('
	o = new stzFrameGraph(64, 64)
	o.AddPass(:X, [ :Writes = [ :a ] ])
	o.Order()
'))
chk("executing an UNSOUND frame is refused", Raises('
	o = new stzFrameGraph(64, 64)
	o.AddPass(:A, [ :Reads = [ :nobodywrites ], :Writes = [ :screen ] ])
	o.Compile()
	o.Execute()
'))

#---------------------------------------------------------------------------
? ""
? "-- 5. It EXECUTES, in one submit ----------------------------"
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- execution skipped; everything above needed none)"
else
	$hPipe = 0
	$aVB = 0
	cWgsl = 'struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) uv: vec2<f32> }
@vertex
fn vmain(@location(0) p: vec2<f32>, @location(1) uv: vec2<f32>) -> VSOut {
  var o: VSOut;  o.pos = vec4<f32>(p, 0.0, 1.0);  o.uv = uv;  return o;
}
@group(0) @binding(0) var tex: texture_2d<f32>;
@group(0) @binding(1) var smp: sampler;
@fragment
fn fmain(in: VSOut) -> @location(0) vec4<f32> {
  let c = textureSample(tex, smp, in.uv);
  return vec4<f32>(1.0 - c.r, 1.0 - c.g, 1.0 - c.b, 1.0);
}'
	$hPipe = StzEngineGpuRenderPipeline(cWgsl, "2,2", 0)
	aQ = [ -1,-1, 0,1,  1,-1, 1,1,  1,1, 1,0,  -1,-1, 0,1,  1,1, 1,0,  -1,1, 0,0 ]
	$aVB = StzEngineGpuBufferNew(len(aQ) * 4)
	StzEngineGpuBufferUploadList($aVB, aQ)

	oX = new stzFrameGraph(256, 256)
	oX.AddPass(:Base,   [ :Writes = [ :base ], :Body = func oF, cN {
			StzEngineGpuRenderBegin(oF.TargetOf(:base), 0.9, 0.3, 0.1, 1)
			StzEngineGpuRenderEnd()
		} ])
	oX.AddPass(:Invert, [ :Reads = [ :base ], :Writes = [ :screen ],
		:Body = func oF, cN {
			StzEngineGpuRenderBegin(oF.TargetOf(:screen), 0, 0, 0, 1)
			StzEngineGpuRenderDraw($hPipe, $aVB, 0, 6, oF.TargetOf(:base))
			StzEngineGpuRenderEnd()
		} ])
	oX.Compile()

	StzEngineGpuCountersReset()
	bRan = oX.Execute()
	StzEngineGpuSync()
	nSub = StzEngineGpuCounter(6)
	? "   executed : " + bRan + "   submits for the whole frame : " + nSub
	chkeq("the whole schedule costs ONE submit", nSub, 1)

	cPix = StzEngineGpuTargetRead(oX.TargetOf(:screen))
	nR = ascii(substr(cPix, 1, 1))
	nG = ascii(substr(cPix, 2, 1))
	? "   first pixel : " + nR + "," + nG + "   (base was 0.9,0.3 -> inverted)"
	chk("pass 2 really read pass 1's target", nR < 60 and nG > 150)

	cPng = StzEngineGpuPngEncode(256, 256, cPix, 1)
	write("gg4_framegraph.png", cPng)
	oX.FreeTargets()
ok

? ""
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

#---------------------------------------------------------------------------

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func chkeq cWhat, xGot, xWant
	chk(cWhat + "  [got " + xGot + ", want " + xWant + "]", xGot = xWant)

func Raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_
