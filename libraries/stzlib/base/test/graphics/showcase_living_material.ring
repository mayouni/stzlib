load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE LIVING MATERIAL -- a Softanza showpiece

	A torus whose surface is not a shader somebody wrote. It is a GRAPH of
	nodes, compiled to the material language, transpiled to WGSL, and
	rebuilt WHILE THE WINDOW IS RUNNING -- and the graph will answer
	questions about itself between frames.

	    1 . . 5   rebuild the material from a different NODE GRAPH
	    T         cycle the theme -- every colour is a MEANING, so the whole
	              scene restyles without a single shape being touched
	    I         INTERROGATE the running material: emission order, what a
	              node affects, the findings. No other engine can answer
	              this while it draws.
	    W         print the material-language body the graph emitted
	    [ ]       the material's scalar, live
	    SPACE     pause the orbit
	    S         save a frame
	    ESC       quit

	WHY IT IS UNIQUE. In every other stack a shader graph is an authoring
	UI: consumed at build time, gone by the time the program runs. Here the
	graph IS the material, it is an stzGraph, and the same reachability that
	answers "which nodes fail if this one does" answers "what does this node
	change" about a surface that is drawing right now.

	Everything visible is written as MEANING: :Primary.Solid, :Danger,
	StzThemeColor(theme, :background). Not one hex value.

	Run:  ring showcase_living_material.ring
---------------------------------------------------------------------------*/

if NOT StzWindowingAvailable()
	? "No windowing here. showcase_living_material_still.png is the still."
	return
ok

decimals(2)

# ---------------------------------------------------------------------------

$nWhich = 3
$nTheme = 1
$nAmt = 0.28
$oScene = NULL
$aSat = []
$nHub = 0
$nRingIdx = 0

# ---------------------------------------------------------------------------

oTorus = new stzMesh([ :Torus, 1.55, 0.52, 96, 48 ])
oBall  = new stzMesh([ :Sphere, 0.17, 20, 14 ])
oHub   = new stzMesh([ :Sphere, 0.30, 24, 16 ])

$oScene = new stzScene(1180, 700)
$oScene.SetCamera(0, 2.6, 6.2, 0, 0, 0)
$oScene.SetLight(-0.42, -0.78, -0.42, "#FFF6E6", "#141A2C")

$oScene.AddMeshQ(oTorus, 0, 0, 0)
nRing = $oScene.LastIndex()
$nRingIdx = nRing

# A HUB the satellites are PARENTED to. Move the hub and the whole swarm
# follows, because a child's transform means "relative to my parent" --
# nothing here computes an absolute position.
$oScene.AddMeshQ(oHub, 0, 0, 0)
$nHub = $oScene.LastIndex()

for i = 1 to 12
	a = 2 * 3.14159265 * (i - 1) / 12
	$oScene.AddMeshQ(oBall, 2.7 * cos(a), 0.5 * sin(a * 2), 2.7 * sin(a))
	$aSat + $oScene.LastIndex()
	$oScene.SetParent($aSat[i], $nHub)
next

Restyle()
oGraph = ApplyMaterial()

# a still, so the demo leaves something behind even after the window closes
$oScene.ToPNG("showcase_living_material_still.png")

oWin = new stzWindow(1180, 700, "Softanza -- The Living Material")
? "=============================================================="
? " THE LIVING MATERIAL"
? "=============================================================="
? "  1..5  rebuild the material from a different NODE GRAPH"
? "  T     cycle theme      I  interrogate the graph"
? "  W     print the emitted material-language body"
? "  [ ]   scalar down/up   SPACE pause   S save   ESC quit"
? ""
? "  material : " + MaterialNames()[$nWhich] + "   theme : " + Themes()[$nTheme]
? ""

nT = 0
bPaused = FALSE

while oWin.IsOpen()
	oWin.Poll()
	if oWin.KeyPressed(:Escape)  exit  ok

	for k = 1 to 5
		if oWin.KeyPressed("" + k)
			$nWhich = k
			oGraph = ApplyMaterial()
			? "material -> " + MaterialNames()[k] +
			  "   nodes " + oGraph.NodeCount() +
			  "   order " + @@(oGraph.Order())
		ok
	next

	if oWin.KeyPressed(:T)
		$nTheme = ($nTheme % len(Themes())) + 1
		Restyle()
		oGraph = ApplyMaterial()
		? "theme -> " + Themes()[$nTheme] +
		  "   primary " + StzResolveColor(StzThemeColor(Themes()[$nTheme], :primary))
	ok

	if oWin.KeyPressed(:I)
		? ""
		? "  --- the material, interrogated WHILE IT DRAWS ---"
		? "  emission order : " + @@(oGraph.Order())
		? "  output node    : " + oGraph.OutputNode()
		? "  lets saved by reuse : " + oGraph.ReuseSaved()
		for a in oGraph.Uses()
			if a[2] > 1
				? "    '" + a[1] + "' is read by " + a[2] + " nodes -> emitted ONCE"
			ok
		next
		aFirst = oGraph.Order()[1]
		? "  changing '" + aFirst + "' affects : " + @@(oGraph.Affects(aFirst))
		? "  findings : " + len(oGraph.Findings()) + "   sound : " + oGraph.IsSound()
		? ""
	ok

	if oWin.KeyPressed(:W)
		? ""
		? "  the graph emitted:"
		? "    " + oGraph.ToW()
		? ""
	ok

	if oWin.KeyPressed(:Space)  bPaused = NOT bPaused  ok

	if oWin.KeyPressed(:S)
		$oScene.ToPNG("showcase_living_material_shot.png")
		? "saved showcase_living_material_shot.png"
	ok

	if oWin.KeyDown(93)   # GLFW ]
		$nAmt = min([ 0.9, $nAmt + 0.01 ])
		ApplyMaterial()
	ok
	if oWin.KeyDown(91)   # GLFW [
		$nAmt = max([ 0.0, $nAmt - 0.01 ])
		ApplyMaterial()
	ok

	if NOT bPaused
		nT += oWin.DeltaTime()
	ok

	# the torus turns on two axes; the swarm counter-rotates around its hub,
	# and the hub itself drifts -- one transform, twelve bodies following
	# RotateTo is AXIS + DEGREES, not three Euler angles. A tilted axis
	# makes the torus tumble rather than spin flat, which is what shows the
	# material off around the whole tube.
	$oScene.RotateTo(nRing, 0.42, 1, 0.28, nT * 26)
	$oScene.RotateTo($nHub, 0, 1, 0, 0 - nT * 30)
	$oScene.MoveTo($nHub, 0, 0.55 * sin(nT * 0.9), 0)

	oWin.Draw($oScene)
end

? ""
? "frames : " + oWin.FrameCount() + "   avg fps : " + oWin.FPS()
oWin.Close()

# ---------------------------------------------------------------------------
# EVERY func LIVES AT THE BOTTOM. Code after a func definition never runs in
# Ring, so with these at the top the whole demo loaded, defined five
# functions and exited without drawing a thing -- silently, with no error.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# THE FIVE MATERIALS, each a NODE GRAPH. Not a string, not a shader --
# nodes and their inputs, with the emission order derived.
# ---------------------------------------------------------------------------

func BuildGraph(nWhich)
	# NO `base` COLOUR UNIFORM. The body colour is "@color" -- the
	# INSTANCE's own colour -- so ONE material carries thirteen different
	# meanings: the torus wears the theme's primary, each satellite wears
	# its own semantic role. A material bound to a single uniform colour
	# would have painted every body identically, and the narration would
	# have been a lie.
	_g_ = new stzMaterialGraph()
		_g_.TakesColor(:accent)
	_g_.TakesScalar(:amt)

	switch nWhich
	on 1     # LIT -- the floor: ambient-lifted lambert
		_g_.AddNode(:lit,  [ :Op = :Lit,      :In = [ :amt ] ])
		_g_.AddNode(:out,  [ :Op = :Multiply, :In = [ "@color", :lit ] ])
	on 2     # BANDED -- latitude rings from world position
		_g_.AddNode(:h,    [ :Op = :Multiply, :In = [ "@position.y", 6.0 ] ])
		_g_.AddNode(:band, [ :Op = :Fract,    :In = [ :h ] ])
		_g_.AddNode(:lit,  [ :Op = :Lit,      :In = [ :amt ] ])
		_g_.AddNode(:mix,  [ :Op = :Mix,      :In = [ "@color", :accent, :band ] ])
		_g_.AddNode(:out,  [ :Op = :Multiply, :In = [ :mix, :lit ] ])
	on 3     # FRESNEL -- the rim glows where the surface turns away
		_g_.AddNode(:rim,  [ :Op = :Fresnel,  :In = [ 2.5 ] ])
		_g_.AddNode(:lit,  [ :Op = :Lit,      :In = [ :amt ] ])
		_g_.AddNode(:body, [ :Op = :Multiply, :In = [ "@color", :lit ] ])
		_g_.AddNode(:out,  [ :Op = :Mix,      :In = [ :body, :accent, :rim ] ])
	on 4     # IRIDESCENT -- two normal axes drive a three-way blend
		_g_.AddNode(:x,    [ :Op = :Multiply, :In = [ "@normal.x", 0.5 ] ])
		_g_.AddNode(:xs,   [ :Op = :Add,      :In = [ :x, 0.5 ] ])
		_g_.AddNode(:z,    [ :Op = :Multiply, :In = [ "@normal.z", 0.5 ] ])
		_g_.AddNode(:zs,   [ :Op = :Add,      :In = [ :z, 0.5 ] ])
		_g_.AddNode(:m1,   [ :Op = :Mix,      :In = [ "@color", :accent, :xs ] ])
		_g_.AddNode(:lit,  [ :Op = :Lit,      :In = [ :amt ] ])
		_g_.AddNode(:m2,   [ :Op = :Mix,      :In = [ :m1, :accent, :zs ] ])
		_g_.AddNode(:out,  [ :Op = :Multiply, :In = [ :m2, :lit ] ])
	on 5     # CONTOUR -- an anti-aliased line, from smoothstep on fract
		_g_.AddNode(:h,    [ :Op = :Multiply, :In = [ "@position.y", 9.0 ] ])
		_g_.AddNode(:f,    [ :Op = :Fract,    :In = [ :h ] ])
		_g_.AddNode(:d,    [ :Op = :Subtract, :In = [ :f, 0.5 ] ])
		_g_.AddNode(:ad,   [ :Op = :Abs,      :In = [ :d ] ])
		_g_.AddNode(:e,    [ :Op = :Smoothstep, :In = [ 0.02, 0.12, :ad ] ])
		_g_.AddNode(:k,    [ :Op = :OneMinus, :In = [ :e ] ])
		_g_.AddNode(:lit,  [ :Op = :Lit,      :In = [ :amt ] ])
		_g_.AddNode(:body, [ :Op = :Multiply, :In = [ "@color", :lit ] ])
		_g_.AddNode(:out,  [ :Op = :Mix,      :In = [ :body, :accent, :k ] ])
	off

	_g_.Emits(:out)
	_g_.Compile()
	return _g_

func MaterialNames()
	return [ "lit", "banded", "fresnel", "iridescent", "contour" ]

func Themes()
	return [ "dark", "vibrant", "pro", "access", "light" ]

func Restyle()
	_t_ = Themes()[$nTheme]
	$oScene.SetBackground(StzThemeColor(_t_, :background))
	# the satellites wear ROLE colours, so a theme change restyles them
	_roles_ = [ :Success, :Warning, :Danger, :Info, :Primary, :Neutral ]
	for _i_ = 1 to len($aSat)
		_r_ = "" + _roles_[ ((_i_ - 1) % 6) + 1 ] + ".Solid"
		$oScene.SetColor($aSat[_i_], _r_)
	next
	$oScene.SetColor($nHub, StzThemeColor(_t_, :neutral))
	# RE-LIT to the solid rung. A theme's primary is chosen for its role in
	# a UI, not for its weight as a 3D surface -- 'dark' names blue-- which
	# is nearly white. StzColorAtLightness puts it at the common solid
	# lightness, which is exactly what C2's .Solid step does for a fill.
	$oScene.SetColor($nRingIdx,
		StzColorAtLightness(StzThemeColor(_t_, :primary), 0.58))

func ApplyMaterial()
	_g_ = BuildGraph($nWhich)
	_t_ = Themes()[$nTheme]
	$oScene.SetMaterial(_g_.ToMaterial(), [
		:accent = StzThemeColor(_t_, :warning),
		:amt    = $nAmt
	])
	return _g_
