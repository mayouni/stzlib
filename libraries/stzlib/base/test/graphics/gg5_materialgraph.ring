load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG5 -- A MATERIAL IS A GRAPH

	The phase the whole graph plane was pointed at. In ShaderGraph a graph
	is SYNTAX: an authoring UI, consumed at compile time, that your program
	can never ask a question. Here it is an stzGraph, so the material
	answers with the same algorithms the rest of the plane uses.

	KILL CRITERION, written in the plan before any of this existed:

	    "needs the LANGUAGE deepened first -- multiple statements, textures,
	     control flow -- the graph front-end is the easy half."

	The language now has lets, textures and swizzles. So this file has to
	show the graph earning its place ON TOP of that: things a hand-written
	W-string cannot do, not things it can.

	Run:  ring gg5_materialgraph.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " GG5 -- the material node graph"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. The order is DERIVED, not declared ---------------------"
#
# The nodes are added in a deliberately WRONG order -- the output first,
# its inputs last. If the emission followed the declaration, every let
# would reference a name that does not exist yet.
#---------------------------------------------------------------------------

oG = new stzMaterialGraph()
oG.TakesColor(:warm)
oG.TakesColor(:cool)
oG.TakesScalar(:sharp)

oG.AddNode(:final, [ :Op = :Mix,      :In = [ :shaded, :warm, :rim ] ])
oG.AddNode(:rim,   [ :Op = :Fresnel,  :In = [ :sharp ] ])
oG.AddNode(:shaded,[ :Op = :Multiply, :In = [ :cool, :lit ] ])
oG.AddNode(:lit,   [ :Op = :Lit,      :In = [ 0.25 ] ])
oG.Emits(:final)
oG.Compile()

? "   declared : final, rim, shaded, lit"
? "   DERIVED  : " + @@(oG.Order())
# CAREFUL what this asserts. 'rim' and 'lit' both read only declared values,
# so EITHER may come first -- a topological order is not unique, and pinning
# position 1 would be asserting a tie-break the sort never promised. What it
# DID promise is the only thing worth checking: every node after all of its
# node-inputs.
chk("the output node is emitted last", oG.Order()[4] = "final")
chk("shaded comes after lit, which it reads",
    _At(oG.Order(), "shaded") > _At(oG.Order(), "lit"))
chk("final comes after both of ITS inputs",
    _At(oG.Order(), "final") > _At(oG.Order(), "shaded") and
    _At(oG.Order(), "final") > _At(oG.Order(), "rim"))

? ""
? "   it emitted:"
? "     " + oG.ToW()
chk("the emission is a material-language body",
    StzFindFirst("let n_lit", oG.ToW()) > 0 and
    StzFindFirst("@out =", oG.ToW()) > 0)
chk("and the lets carry the derived order",
    StzFindFirst("let n_lit", oG.ToW()) < StzFindFirst("let n_shaded", oG.ToW()))

#---------------------------------------------------------------------------
? ""
? "-- 2. It TRANSPILES and RENDERS ------------------------------"
#
# A graph that emits plausible text is not a material. The emission goes
# through the SAME transpiler a hand-written body does -- one set of rules,
# not two that must be kept in agreement.
#---------------------------------------------------------------------------

cW = oG.ToWGSL()
? "   " + len(cW) + " chars of WGSL, via stzMaterialMaker"
chk("the graph's emission compiles", len(cW) > 200 and StzFindFirst("@fragment", cW) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 3. REUSE: a node read twice is emitted ONCE ---------------"
#
# The dividend of a DAG over a tree, and the thing a hand-written body has
# to remember to do. Kept as a NUMBER so the claim is checkable.
#---------------------------------------------------------------------------

oReuse = new stzMaterialGraph()
oReuse.TakesColor(:base)
oReuse.TakesScalar(:freq)
oReuse.AddNode(:band,  [ :Op = :Fract,    :In = [ :scaled ] ])
oReuse.AddNode(:scaled,[ :Op = :Multiply, :In = [ "@position.y", :freq ] ])
oReuse.AddNode(:soft,  [ :Op = :Smoothstep, :In = [ 0.2, 0.8, :band ] ])
# `band` is read by BOTH soft and edge -- one node, two consumers
oReuse.AddNode(:edge,  [ :Op = :OneMinus, :In = [ :band ] ])
oReuse.AddNode(:mixed, [ :Op = :Mix,      :In = [ :base, :soft, :edge ] ])
oReuse.Emits(:mixed)
oReuse.Compile()

for a in oReuse.Uses()
	? "     " + PadR(a[1], 8) + " read by " + a[2] + " node(s)"
next
? "   lets saved over a tree expansion : " + oReuse.ReuseSaved()
chkeq("'band' has two consumers", _UseOf(oReuse.Uses(), "band"), 2)
chkeq("...so one subtree is not re-emitted", oReuse.ReuseSaved(), 1)

cWR = oReuse.ToW()
nFirst = StzFindFirst("let n_band", cWR)
cTail = StzSubStr(cWR, nFirst + 5, len(cWR) - nFirst - 4)
chk("'band' is BOUND once", StzFindFirst("let n_band", cTail) = 0)
chk("...and REFERENCED twice", _Count(cWR, "n_band") = 3)   # 1 let + 2 reads
? "   n_band appears " + _Count(cWR, "n_band") + " times: one let, two reads"

#---------------------------------------------------------------------------
? ""
? "-- 4. The question ShaderGraph cannot answer -----------------"
#
# "What does this node affect?" is a REACHABILITY query. A material that
# answers it is a computational object; one that cannot is a picture of one.
#---------------------------------------------------------------------------

aImp = oReuse.Affects(:band)
? "   changing 'band' affects : " + @@(aImp)
chk("band reaches soft", _Has(aImp, "soft"))
chk("band reaches edge", _Has(aImp, "edge"))
chk("band reaches the output", _Has(aImp, "mixed"))
chk("but NOT the node that FEEDS it -- reachability has a direction",
    NOT _Has(aImp, "scaled"))
chkeq("Affects() and ImpactOf() agree", len(aImp), oReuse.ImpactOf(:band))

aImp2 = oReuse.Affects(:soft)
? "   changing 'soft' affects  : " + @@(aImp2)
chk("a node nearer the output affects FEWER things", len(aImp2) < len(aImp))

# the negative sibling: the SOURCE of the chain must affect everything
chkeq("the deepest node affects every other one",
      oReuse.ImpactOf(:scaled), oReuse.NodeCount() - 1)

#---------------------------------------------------------------------------
? ""
? "-- 5. The proofs, in the house finding shape -----------------"
#---------------------------------------------------------------------------

chk("a sound graph reports sound", oG.IsSound())
chkeq("and has no findings", len(oG.Findings()), 0)

# a CYCLE: two nodes each reading the other
oC = new stzMaterialGraph()
oC.TakesColor(:c)
oC.AddNode(:a, [ :Op = :Multiply, :In = [ :b, :c ] ])
oC.AddNode(:b, [ :Op = :Multiply, :In = [ :a, :c ] ])
oC.Emits(:a)
oC.Compile()
chk("a CYCLE is detected", NOT oC.IsSound())
? "   cycle finding : " + oC.Findings()[1][5]

# an input nobody provides
oU = new stzMaterialGraph()
oU.AddNode(:x, [ :Op = :Fract, :In = [ :nowhere ] ])
oU.Emits(:x)
oU.Compile()
chk("an unresolved input is an ERROR", NOT oU.IsSound())
? "   unresolved    : " + oU.Findings()[1][5]

# a typo'd builtin caught HERE, with the node's name
oB = new stzMaterialGraph()
oB.AddNode(:x, [ :Op = :Fract, :In = [ "@sparkle" ] ])
oB.Emits(:x)
oB.Compile()
chk("a bad builtin is caught with the NODE named", NOT oB.IsSound())
chk("  ...and the message names it", StzFindFirst("sparkle", oB.Findings()[1][5]) > 0)

# DEAD WORK: computed for nobody
oD = new stzMaterialGraph()
oD.TakesColor(:c)
oD.TakesScalar(:s)
oD.AddNode(:used,  [ :Op = :Fresnel,  :In = [ :s ] ])
oD.AddNode(:waste, [ :Op = :Fract,    :In = [ "@lambert" ] ])
oD.AddNode(:out,   [ :Op = :Multiply, :In = [ :c, :used ] ])
oD.Emits(:out)
oD.Compile()
chk("dead work is a WARNING, not an error", oD.IsSound())
chkeq("  ...and it is reported", len(oD.Findings()), 1)
? "   dead finding  : " + oD.Findings()[1][5]

oRep = oC.Report()
chk("the findings reach stzRuleReport", isObject(oRep))

#---------------------------------------------------------------------------
? ""
? "-- 6. Refusals name themselves ------------------------------"
#---------------------------------------------------------------------------

chk("an unknown op is refused (and lists the ops)", Raises('
	o = new stzMaterialGraph()
	o.AddNode(:x, [ :Op = :Sparkle, :In = [ 1 ] ])
'))
chk("the wrong ARITY is refused", Raises('
	o = new stzMaterialGraph()
	o.AddNode(:x, [ :Op = :Mix, :In = [ 1, 2 ] ])
'))
chk("a node declared twice is refused", Raises('
	o = new stzMaterialGraph()
	o.AddNode(:x, [ :Op = :Fract, :In = [ 1 ] ])
	o.AddNode(:x, [ :Op = :Fract, :In = [ 2 ] ])
'))
chk("a node shadowing a declared colour is refused", Raises('
	o = new stzMaterialGraph()
	o.TakesColor(:tint)
	o.AddNode(:tint, [ :Op = :Fract, :In = [ 1 ] ])
'))
chk("no output is refused", Raises('
	o = new stzMaterialGraph()
	o.AddNode(:x, [ :Op = :Fract, :In = [ 1 ] ])
	o.Compile()
'))
chk("asking before Compile is refused", Raises('
	o = new stzMaterialGraph()
	o.AddNode(:x, [ :Op = :Fract, :In = [ 1 ] ])
	o.Emits(:x)
	o.Order()
'))
chk("emitting from an UNSOUND graph is refused", Raises('
	o = new stzMaterialGraph()
	o.AddNode(:x, [ :Op = :Fract, :In = [ :ghost ] ])
	o.Emits(:x)
	o.Compile()
	o.ToW()
'))

#---------------------------------------------------------------------------
? ""
? "-- 7. And it DRAWS ------------------------------------------"
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- everything above needed none)"
else
	oMesh = new stzMesh([ :Sphere, 1.3, 80, 52 ])

	# A graph built from the pieces: a texture sampled, banded by height,
	# rimmed, and shaded. Written as NODES -- no W-string anywhere.
	TW = 256  TH = 256
	oCv = new stzCanvas(TW, TH)
	oCv.SetBackgroundQ("#0D1830")
	for k = 0 to 7
		for j = 0 to 7
			if (k + j) % 2 = 0
				oCv.AddRectQ(k * 32, j * 32, 32, 32).
				    FillQ(StzColorFromHSL(20 + k * 18, 65, 55))
			ok
		next
	next
	hTex = StzEngineGpuTextureNew(TW, TH, 2)
	StzEngineGpuTextureWrite(hTex, oCv.ToPixels())

	oM = new stzMaterialGraph()
	oM.TakesTexture(:art)
	oM.TakesColor(:glow)
	oM.TakesScalar(:sharp)
	oM.TakesScalar(:amb)

	oM.AddNode(:pic,  [ :Op = :Sample,   :In = [ :art, "@uv" ] ])
	oM.AddNode(:lit,  [ :Op = :Lit,      :In = [ :amb ] ])
	oM.AddNode(:body, [ :Op = :Multiply, :In = [ :pic, :lit ] ])
	oM.AddNode(:rim,  [ :Op = :Fresnel,  :In = [ :sharp ] ])
	oM.AddNode(:out,  [ :Op = :Mix,      :In = [ :body, :glow, :rim ] ])
	oM.Emits(:out)
	oM.Compile()
	? "   the graph emitted:"
	? "     " + oM.ToW()

	oSc = new stzScene(560, 560)
	oSc.SetBackgroundQ("#05070F").SetCamera(0, 1.2, 3.7, 0, 0, 0)
	oSc.SetLight(-0.45, -0.75, -0.4, "#FFF6E6", "#1A2036")
	oSc.AddMesh(oMesh, 0, 0, 0)
	oSc.SetMaterial(oM.ToMaterial(),
		[ :art = hTex, :glow = "#FF9A40", :sharp = 2.5, :amb = 0.28 ])
	oSc.ToPNG("gg5_materialgraph.png")
	? "   wrote gg5_materialgraph.png"

	cPx = oSc.ToPixels()
	nInk = 0  aSeen = []
	nPixLen = len(cPx)
	for i = 1 to nPixLen step 409
		v = ascii(substr(cPx, i, 1))
		if v > 40
			nInk++
			if NOT StzFind(v, aSeen)  aSeen + v  ok
		ok
	next
	? "   ink " + nInk + "   distinct levels " + len(aSeen)
	chk("the graph's material drew a real surface", nInk > 150 and len(aSeen) > 40)

	# CHANGE ONE NODE and the picture must follow -- the claim that the
	# graph is the material, not a description of one that was compiled
	# somewhere else and left behind.
	oM2 = new stzMaterialGraph()
	oM2.TakesTexture(:art)
	oM2.TakesColor(:glow)
	oM2.TakesScalar(:sharp)
	oM2.TakesScalar(:amb)
	oM2.AddNode(:pic,  [ :Op = :Sample,   :In = [ :art, "@uv" ] ])
	oM2.AddNode(:lit,  [ :Op = :Lit,      :In = [ :amb ] ])
	oM2.AddNode(:body, [ :Op = :Multiply, :In = [ :pic, :lit ] ])
	oM2.AddNode(:rim,  [ :Op = :Fresnel,  :In = [ :sharp ] ])
	# the one difference: the rim is INVERTED
	oM2.AddNode(:flip, [ :Op = :OneMinus, :In = [ :rim ] ])
	oM2.AddNode(:out,  [ :Op = :Mix,      :In = [ :body, :glow, :flip ] ])
	oM2.Emits(:out)
	oM2.Compile()

	oSc.SetMaterial(oM2.ToMaterial(),
		[ :art = hTex, :glow = "#FF9A40", :sharp = 2.5, :amb = 0.28 ])
	oSc.ToPNG("gg5_materialgraph_flip.png")
	cPx2 = oSc.ToPixels()

	nDiff = 0
	for i = 1 to nPixLen step 337
		if substr(cPx, i, 1) != substr(cPx2, i, 1)  nDiff++  ok
	next
	? "   one node added, " + nDiff + " of " + floor(nPixLen / 337) + " sampled bytes changed"
	chk("editing ONE node changes the picture", nDiff > 200)
	chkeq("...and the graph grew by exactly one node",
	      oM2.NodeCount() - oM.NodeCount(), 1)
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

func _At aList, cWhat
	_n_ = len(aList)
	for _i_ = 1 to _n_
		if StzLower("" + aList[_i_]) = cWhat  return _i_  ok
	next
	return 0

func _Has aList, cWhat
	return _At(aList, cWhat) > 0

func _UseOf aUses, cName
	for _a_ in aUses
		if _a_[1] = cName  return _a_[2]  ok
	next
	return -1

func _Count cHay, cNeedle
	return len(StzFindCS(cNeedle, cHay, TRUE))
