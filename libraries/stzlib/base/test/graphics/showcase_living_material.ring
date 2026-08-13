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
$nPanel = 0     # 0 none, 1 = what the graph knows, 2 = its code

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

oHudFont = NULL
if fexists("C:/Windows/Fonts/segoeui.ttf")
	oHudFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
ok

oWin = new stzWindow(1180, 700, "Softanza -- The Living Material")
? "=============================================================="
? " THE LIVING MATERIAL"
? "=============================================================="
? "  Everything below is ALSO shown in the window itself."
? ""
? "  1-5    change the surface -- each is a different NODE GRAPH"
? "  T      change the colour theme"
? "  I      show what the material knows about ITSELF"
? "  W      show the material's own code"
? "  [ / ]  less / more ambient light"
? "  SPACE  pause      S  save a picture      ESC  quit"
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

	# I AND W SHOW THEIR ANSWER ON THE SCREEN, not in the terminal.
	# They used to print to the console -- which is the window you are NOT
	# looking at while the render has focus, so pressing I looked like
	# nothing happened at all. Output that answers a keypress belongs where
	# the keypress was made.
	if oWin.KeyPressed(:I)
		$nPanel = iif($nPanel = 1, 0, 1)
	ok

	if oWin.KeyPressed(:W)
		$nPanel = iif($nPanel = 2, 0, 2)
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

	# the HUD is rebuilt each frame -- it is a handful of shapes, and the
	# scene's own buffers are the ones that matter for cost
	oHud = BuildHud(oWin.Width(), oWin.Height(), oHudFont,
		MaterialNames()[$nWhich], Themes()[$nTheme], $nAmt, floor(oWin.FPS()),
		oGraph, $nPanel)
	oWin.DrawXT($oScene, oHud)
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

# ---------------------------------------------------------------------------
# THE HUD. An stzCanvas drawn OVER the 3D frame in the same acquired frame
# (stzWindow.DrawXT), so the controls are on screen rather than in a comment
# nobody reading the window can see.
#
# Its background is TRANSPARENT and it is drawn with a preserving pass, so
# it annotates the render instead of replacing it.
# ---------------------------------------------------------------------------
func BuildHud(nW, nH, oFont, cMat, cTheme, nAmt, nFps, oGraph, nPanel)
	_o_ = new stzCanvas(nW, nH)
	_o_.SetBackground("#00000000")            # transparent: annotate, do not replace
	if NOT isObject(oFont)  return _o_  ok

	# TYPE SIZES. The first version used 11-13 px, which is a comment font,
	# not a font for a thing being read from across a desk while something
	# moves behind it. Everything here is at least 16.
	_TITLE_ = 30
	_BODY_  = 17
	_SMALL_ = 15

	_o_.Flush()
	# THE PANEL IS SIZED FROM THE ROWS, not typed. The first version fixed
	# it at 330 px and the last two keys fell outside the plate they were
	# meant to sit on -- a layout that stops being right the moment a row
	# is added is a layout that will be wrong again.
	_nRows_ = 8
	_nPanelH_ = 140 + _nRows_ * 34 - 10
	_o_.FillQ("#0B1020E8").AddRoundRect(24, 24, 470, _nPanelH_, 14)

	_o_.Flush()
	_o_.AddTextQ("THE LIVING MATERIAL", 48, 72).SetFontQ(oFont, _TITLE_).Color(:White)
	_o_.Flush()
	_o_.AddTextQ("this surface is not a shader -- it is a graph of nodes",
		48, 100).SetFontQ(oFont, _SMALL_).Color("#9FB0D8")

	# PLAIN WORDING. "interrogate the graph" told the reader what I was
	# proud of, not what the key does.
	_aRows_ = [
		[ "1-5",   "change the surface" ],
		[ "T",     "change the colour theme" ],
		[ "I",     "what the material knows about itself" ],
		[ "W",     "the material's own code" ],
		[ "[ / ]", "less / more ambient light" ],
		[ "SPACE", "pause" ],
		[ "S",     "save a picture" ],
		[ "ESC",   "quit" ]
	]
	_y_ = 140
	for _r_ in _aRows_
		_o_.Flush()
		_o_.FillQ("Info.Solid").AddRoundRect(48, _y_ - 18, 74, 28, 6)
		_o_.Flush()
		_o_.AddTextQ(_r_[1], 56, _y_ + 2).SetFontQ(oFont, _SMALL_).Color("OnInfo")
		_o_.Flush()
		_o_.AddTextQ(_r_[2], 138, _y_ + 2).SetFontQ(oFont, _BODY_).Color("#E4EAF7")
		_y_ += 34
	next

	# the live state
	_o_.Flush()
	_o_.FillQ("#0B1020E8").AddRoundRect(24, nH - 92, 620, 68, 14)
	_o_.Flush()
	_o_.AddTextQ("surface  " + cMat + "        theme  " + cTheme +
		"        light  " + nAmt + "        " + nFps + " fps",
		48, nH - 56).SetFontQ(oFont, _BODY_).Color(:White)
	_o_.Flush()
	_o_.AddTextQ("one material, thirteen colours -- each body carries its own meaning",
		48, nH - 34).SetFontQ(oFont, _SMALL_).Color("#9FB0D8")

	if nPanel = 0 or NOT isObject(oGraph)  return _o_  ok

	# ---- the answer panel, on the RIGHT --------------------------------
	_px_ = nW - 560
	_o_.Flush()
	_o_.FillQ("#0B1020E8").AddRoundRect(_px_, 24, 536, 300, 14)

	_aLines_ = []
	if nPanel = 1
		_aLines_ + [ "WHAT THE MATERIAL KNOWS ABOUT ITSELF", 1 ]
		_aLines_ + [ "asked while it is drawing, not at build time", 2 ]
		_aLines_ + [ "", 0 ]
		_aLines_ + [ "it has " + oGraph.NodeCount() + " nodes, and works them out in", 0 ]
		_aLines_ + [ "this order:  " + _Join(oGraph.Order()), 3 ]
		_aLines_ + [ "", 0 ]
		_aFirst_ = oGraph.Order()[1]
		_aLines_ + [ "change '" + _aFirst_ + "' and it changes:", 0 ]
		_aLines_ + [ "   " + _Join(oGraph.Affects(_aFirst_)), 3 ]
		_aLines_ + [ "", 0 ]
		_aLines_ + [ "steps saved by reusing a node: " + oGraph.ReuseSaved(), 0 ]
		_aLines_ + [ "problems found: " + len(oGraph.Findings()), 0 ]
	else
		_aLines_ + [ "THE MATERIAL'S OWN CODE", 1 ]
		_aLines_ + [ "the graph wrote this; nobody typed it", 2 ]
		_aLines_ + [ "", 0 ]
		for _seg_ in _Wrap(oGraph.ToW(), 58)
			_aLines_ + [ _seg_, 3 ]
		next
	ok

	_ly_ = 66
	for _l_ in _aLines_
		if _l_[1] != ""
			_sz_ = _BODY_
			_col_ = "#E4EAF7"
			if _l_[2] = 1  _sz_ = 21  _col_ = "#FFFFFF"  ok
			if _l_[2] = 2  _sz_ = _SMALL_  _col_ = "#9FB0D8"  ok
			if _l_[2] = 3  _col_ = "#8FE3C0"  ok
			_o_.Flush()
			_o_.AddTextQ(_l_[1], _px_ + 24, _ly_).SetFontQ(oFont, _sz_).Color(_col_)
		ok
		_ly_ += 24
	next
	return _o_

# A list of ids as plain prose, not @@() -- a reader should not have to
# parse Ring's list notation off a moving screen.
func _Join aList
	_c_ = ""
	for _x_ in aList
		if _c_ != ""  _c_ += ", "  ok
		_c_ += "" + _x_
	next
	if _c_ = ""  _c_ = "(nothing)"  ok
	return _c_

# Break a long line on spaces so the emitted code fits the panel.
func _Wrap cText, nWidth
	_a_ = []
	_cur_ = ""
	for _w_ in StzSplit(cText, " ")
		if len(_cur_) + len(_w_) + 1 > nWidth
			_a_ + _cur_
			_cur_ = _w_
		else
			if _cur_ = ""
				_cur_ = _w_
			else
				_cur_ += " " + _w_
			ok
		ok
	next
	if _cur_ != ""  _a_ + _cur_  ok
	return _a_
