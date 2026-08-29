load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	PARITY WITH DOT -- the same picture, the same semantics

	The documentation (stzOrgChartDoc.md) shows five renders that came from
	graphviz. This file reproduces each of them from the NATIVE tier and
	names, honestly, what is matched and what is not.

	What "parity" has to mean here is not "pixel-identical" -- dot's exact
	spline control points and rank spacing are its own. It means the reader
	of the picture gets the SAME INFORMATION:

	  the semantic COLOURS (executive gold, management blue, staff green,
	  focus magenta) resolved through the SAME $aOrgColors the dot path uses
	  the LABEL inside the node, legible against its own fill
	  the SHAPE the node declared
	  ARROWS that show direction and stop at the node, not under it
	  CLUSTERS as labelled boxes around their members
	  rankdir: TB and LR
	  the spline style the diagram asked for: spline / ortho / curved / line

	Run:  ring gg_diagram_parity.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0
FONT = "C:/Windows/Fonts/segoeui.ttf"

? "=============================================================="
? " PARITY WITH DOT -- the documentation's own pictures"
? "=============================================================="

oFont = NULL
if fexists(FONT)
	oFont = new stzFont(FONT)
ok
? ""
? "   font : " + iif(isObject(oFont), FONT, "(none -- labels will be skipped)")
chk("a font is available, so labels can be tested", isObject(oFont))

#---------------------------------------------------------------------------
? ""
? "-- 1. The basic hierarchy (orgchart1.png) -------------------"
#
# Executive gold, management blue, staff green -- the SAME semantic colours
# the dot path resolves, read from $aOrgColors rather than typed here.
#---------------------------------------------------------------------------

? "   $aOrgColors executive = " + $aOrgColors[:executive] +
  "   management = " + $aOrgColors[:management] +
  "   staff = " + $aOrgColors[:staff]

oOrg = new stzDiagram("Basic_Hierarchy")
oOrg.SetLayout("TD")
oOrg.AddNodeXTT(:ceo,       "CEO",         [ :type = "box", :color = $aOrgColors[:executive] ])
oOrg.AddNodeXTT(:vp_sales,  "VP Sales",    [ :type = "box", :color = $aOrgColors[:management] ])
oOrg.AddNodeXTT(:vp_eng,    "VP Engineering", [ :type = "box", :color = $aOrgColors[:management] ])
oOrg.AddNodeXTT(:sales_rep1,"Sales Rep 1", [ :type = "box", :color = $aOrgColors[:staff] ])
oOrg.AddNodeXTT(:dev1,      "Developer 1", [ :type = "box", :color = $aOrgColors[:staff] ])
oOrg.AddEdge(:ceo, :vp_sales)
oOrg.AddEdge(:ceo, :vp_eng)
oOrg.AddEdge(:vp_sales, :sales_rep1)
oOrg.AddEdge(:vp_eng, :dev1)

aOpt = [ :Width = 720, :Height = 560, :Font = oFont, :FontSize = 14 ]
oOrg.ToPNGXT("parity_1_hierarchy.png", aOpt)
write("parity_1_hierarchy.svg", oOrg.ToSVGXT(aOpt))
? "   wrote parity_1_hierarchy.png / .svg"

# THE SEMANTIC COLOURS MUST SURVIVE THE ROUND TRIP. "gold-" is a Softanza
# colour EXPRESSION, not a hex string, and the whole point of reading
# $aOrgColors is that the native tier resolves it the same way dot's
# attribute writer does.
cExec = oOrg.ContrastingTextColor(ResolveColor($aOrgColors[:executive]))
cMgmt = oOrg.ContrastingTextColor(ResolveColor($aOrgColors[:management]))
? "   text on executive gold : " + cExec
? "   text on management blue: " + cMgmt
chk("the label colour ADAPTS to the fill (dark on gold, light on blue)",
    StzLower(cExec) != StzLower(cMgmt))

#---------------------------------------------------------------------------
? ""
? "-- 2. Focus highlighting (orgchart2.png) --------------------"
#
# ViewPopulated() paints occupied positions in the focus colour and leaves
# the rest white. Same semantics here, same $aOrgColors[:focus].
#---------------------------------------------------------------------------

oFoc = new stzDiagram("People_Management")
oFoc.AddNodeXTT(:ceo, "ceo", [ :type = "box", :color = $aOrgColors[:focus] ])
oFoc.AddNodeXTT(:vp,  "vp",  [ :type = "box", :color = $aOrgColors[:focus] ])
oFoc.AddNodeXTT(:cto, "cto", [ :type = "box", :color = "white" ])
oFoc.AddEdge(:ceo, :vp)
oFoc.AddEdge(:ceo, :cto)
oFoc.ToPNGXT("parity_2_focus.png",
	[ :Width = 520, :Height = 380, :Font = oFont, :NodeWidth = 110, :NodeHeight = 48 ])
? "   wrote parity_2_focus.png   (focus = " + $aOrgColors[:focus] + ")"
chk("the focus colour resolves to a real colour",
    len(ResolveColor($aOrgColors[:focus])) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 3. Departments as labelled clusters (orgchart6.png) ------"
#---------------------------------------------------------------------------

oDep = new stzDiagram("Department_Management")
oDep.AddNodeXTT(:ceo,       "CEO",                  [ :type = "box", :color = $aOrgColors[:executive] ])
oDep.AddNodeXTT(:sales_mgr, "Sales Manager",        [ :type = "box", :color = "blue" ])
oDep.AddNodeXTT(:eng_mgr,   "Engineering Manager",  [ :type = "box", :color = $aOrgColors[:staff] ])
oDep.AddEdge(:ceo, :sales_mgr)
oDep.AddEdge(:ceo, :eng_mgr)
oDep.AddClusterXTT(:exec,  "EXECUTIVE",   [ :ceo ],       "magenta")
oDep.AddClusterXTT(:sales, "SALES",       [ :sales_mgr ], "magenta")
oDep.AddClusterXTT(:eng,   "ENGINEERING", [ :eng_mgr ],   "magenta")
oDep.ToPNGXT("parity_3_clusters.png",
	[ :Width = 760, :Height = 470, :Font = oFont, :NodeWidth = 170 ])
? "   wrote parity_3_clusters.png   (3 labelled clusters)"
chkeq("all three departments became clusters", len(oDep.Clusters()), 3)

#---------------------------------------------------------------------------
? ""
? "-- 4. LeftRight + curved (the bank chart) -------------------"
#---------------------------------------------------------------------------

oBank = new stzDiagram("Softabank")
oBank.SetLayout(:LeftRight)
oBank.SetSplines("curved")
oBank.AddNodeXTT(:board,  "Board of Directors", [ :type = "box", :color = "gold" ])
oBank.AddNodeXTT(:ceo,    "CEO",                [ :type = "box", :color = "gold" ])
oBank.AddNodeXTT(:audit,  "Director Internal Audit", [ :type = "box", :color = $aOrgColors[:management] ])
oBank.AddNodeXTT(:risk,   "Chief Risk Officer", [ :type = "box", :color = $aOrgColors[:management] ])
oBank.AddNodeXTT(:sales,  "VP Sales",           [ :type = "box", :color = $aOrgColors[:management] ])
oBank.AddNodeXTT(:eng,    "VP Engineering",     [ :type = "box", :color = $aOrgColors[:management] ])
oBank.AddNodeXTT(:repa,   "Sales Rep A",        [ :type = "box", :color = $aOrgColors[:staff] ])
oBank.AddNodeXTT(:repb,   "Sales Rep B",        [ :type = "box", :color = $aOrgColors[:staff] ])
oBank.AddNodeXTT(:deva,   "Developer A",        [ :type = "box", :color = $aOrgColors[:staff] ])
oBank.AddNodeXTT(:devb,   "Developer B",        [ :type = "box", :color = $aOrgColors[:staff] ])
oBank.AddEdge(:board, :ceo)
oBank.AddEdge(:board, :audit)
oBank.AddEdge(:board, :risk)
oBank.AddEdge(:ceo, :sales)
oBank.AddEdge(:ceo, :eng)
oBank.AddEdge(:sales, :repa)
oBank.AddEdge(:sales, :repb)
oBank.AddEdge(:eng, :deva)
oBank.AddEdge(:eng, :devb)

chkeq("the diagram reports rankdir LR from its own SetLayout",
      oBank._NativeRankDir(), "LR")
oBank.ToPNGXT("parity_4_bank_lr.png",
	[ :Width = 1100, :Height = 720, :Font = oFont, :NodeWidth = 168 ])
? "   wrote parity_4_bank_lr.png   (rankdir LR, curved splines)"

#---------------------------------------------------------------------------
? ""
? "-- 5. Orthogonal splines (orgchart10.png) -------------------"
#---------------------------------------------------------------------------

oOrtho = new stzDiagram("Ortho")
oOrtho.SetSplines("ortho")
oOrtho.AddNodeXTT(:ceo, "ceo", [ :type = "box", :color = $aOrgColors[:focus] ])
oOrtho.AddNodeXTT(:vp,  "vp",  [ :type = "box", :color = $aOrgColors[:focus] ])
oOrtho.AddNodeXTT(:cto, "cto", [ :type = "box", :color = "white" ])
oOrtho.AddEdge(:ceo, :vp)
oOrtho.AddEdge(:ceo, :cto)
chkeq("the diagram reports its own spline style",
      StzLower("" + oOrtho.Splines()), "ortho")
oOrtho.ToPNGXT("parity_5_ortho.png",
	[ :Width = 520, :Height = 380, :Font = oFont, :NodeWidth = 110, :NodeHeight = 48 ])
? "   wrote parity_5_ortho.png"

# every style must actually CHANGE the picture, or the option is decorative
if StzGraphicsDevice()
	aSeen = []
	# ...ASKED WHERE THE STYLES HAVE SOMETHING TO DISAGREE ABOUT.
	#
	# This used two nodes, one above the other. Between two ALIGNED
	# cells an orthogonal route and a straight line are the same
	# picture -- there is nothing to turn -- and the two answers
	# differed only because the ortho path carried a redundant point in
	# the middle of its own straight run. Invisible in the drawing, and
	# the whole of what this assertion was measuring: it went red the
	# day those points were cleaned up, having never tested the claim it
	# names.
	#
	# A third cell puts b off the centre line, so ortho must turn a
	# corner where line runs diagonally, and the difference is one a
	# reader can see.
	_aCS88_ = [ "line", "ortho", "curved", "spline" ]
	_nCS88_ = len(_aCS88_)
	for _iCS88_ = 1 to _nCS88_
		cS = _aCS88_[_iCS88_]
		oT = new stzDiagram("t" + cS)
		oT.SetSplines(cS)
		oT.AddNodeXTT(:a, "a", [ :type = "box", :color = "blue" ])
		oT.AddNodeXTT(:b, "b", [ :type = "box", :color = "blue" ])
		oT.AddNodeXTT(:c, "c", [ :type = "box", :color = "blue" ])
		oT.AddEdge(:a, :b)
		oT.AddEdge(:a, :c)
		aSeen + [ cS, len(oT.ToSVGXT([ :Width = 400, :Height = 300 ])) ]
	next
	_aA89_ = aSeen
	_nA89_ = len(_aA89_)
	for _iA89_ = 1 to _nA89_
		a = _aA89_[_iA89_]
		? "   spline '" + PadR(a[1], 7) + "' -> " + a[2] + " chars of SVG"
	next
	chk("'ortho' and 'line' produce DIFFERENT geometry",
	    aSeen[1][2] != aSeen[2][2])
	chk("'curved' differs from 'line' too", aSeen[3][2] != aSeen[1][2])
ok

#---------------------------------------------------------------------------
? ""
? "-- 6. What is NOT at parity, said out loud ------------------"
#---------------------------------------------------------------------------

? "   - NESTED clusters: a cluster inside a cluster is not drawn."
? "   - Edge LABELS: dot draws them; this does not yet."
? "   - Splines are not ROUTED AROUND nodes -- a curve may cross a box"
? "     that sits between its endpoints. dot's router avoids that."
? "   - Rank SPACING is the layout's, not dot's, so the two pictures are"
? "     recognisably the same chart without being pixel-identical."
? ""
? "   ToDot() remains exact for all four."

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

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_
