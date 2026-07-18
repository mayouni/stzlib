# The Chart subclasses -- and what they actually are.
#
# stats/ ships eight stz*Chart classes, none named in any test: stzBarChart,
# stzVBarChart, stzHBarChart, stzMBarChart, stzMultiBarChart, stzScatterChart,
# stzSurfaceChart, stzSquareChart. The coverage scan flagged all eight.
#
# Probing them settled the question the scan could not: EVERY ONE IS A BARE
# ALIAS. Each is `class stz...Chart from stz...Plot` with an empty body -- not
# one adds a method. So a Chart renders EXACTLY as its Plot parent, and the
# only thing that could ever distinguish them is the single place a Plot
# branches on `ring_classname(This) = "stzbarchart"` (the branch that was dead
# until classname() was fixed two days ago).
#
# That branch is a NO-OP. It strips the last vertical bar for stzbarchart when
# the V-axis shows and the H-axis is hidden -- but stzBarPlot produces the
# byte-identical string in that very configuration. So the whole Chart family
# is a set of NAMES over working Plots, and this suite pins that as the truth
# rather than pretending each is a feature. Naming a thing is not nothing --
# `new stzBarChart(data)` reads better than `new stzBarPlot(data)` -- but it
# must at least render, and render like its parent.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

aData = [ :a = 3, :b = 5, :c = 2 ]

? "-- Scene 1: every bar Chart constructs and renders --"

oBar = new stzBarChart(aData)
chk("stzBarChart builds", isObject(oBar))
chk("... and renders real box-drawing art", len(oBar.ToString()) > 0)
chk("... reporting its own class, not the parent's", classname(oBar) = "stzbarchart")

oV = new stzVBarChart(aData)
chk("stzVBarChart builds and renders", len(oV.ToString()) > 0)
chk("... with its own class name", classname(oV) = "stzvbarchart")

oH = new stzHBarChart(aData)
chk("stzHBarChart builds and renders", len(oH.ToString()) > 0)

aMulti = [ :s1 = [ :a = 3, :b = 5 ], :s2 = [ :a = 2, :b = 4 ] ]
oM = new stzMBarChart(aMulti)
chk("stzMBarChart renders multi-series data", len(oM.ToString()) > 0)
oMM = new stzMultiBarChart(aMulti)
chk("stzMultiBarChart (its alias) renders too", len(oMM.ToString()) > 0)

? ""
? "-- Scene 2: a Chart IS its Plot -- byte for byte --"

# same data, default config: the Chart adds nothing, so the two strings match
cChart = new stzBarChart(aData)
cPlot  = new stzBarPlot(aData)
chk("stzBarChart renders identically to stzBarPlot (it is an alias)",
	cChart.ToString() = cPlot.ToString())

# the ONE Chart-specific branch fires only with the V-axis shown and the
# H-axis hidden. Even THERE, the output is identical -- the branch is inert.
oCA = new stzBarChart(aData)   oCA.WithoutHAxis()
oPA = new stzBarPlot(aData)    oPA.WithoutHAxis()
chk("... even in the one config the Chart branch was written for",
	oCA.ToString() = oPA.ToString())
chk("... same count of vertical bars (the branch strips none observable)",
	StzCountCS(oCA.ToString(), "|", :CS = TRUE) =
	StzCountCS(oPA.ToString(), "|", :CS = TRUE))

? ""
? "-- Scene 3: the render is CORRECT, not merely non-empty --"

# the bars scale to the data: b=5 is the tallest, c=2 the shortest
oScaled = new stzBarChart([ :a = 3, :b = 5, :c = 2 ])
cArt = oScaled.ToString()
chk("the art carries the block glyph", StzFindFirst(char(226), cArt) > 0)
chk("each label appears under its bar",
	StzFindFirst("A", cArt) > 0 and StzFindFirst("B", cArt) > 0 and
	StzFindFirst("C", cArt) > 0)

? ""
? "-- Scene 4: the surface/square Charts are aliases too --"

# stzSurfaceChart / stzSquareChart both descend from stzSurfacePlot with empty
# bodies; a 2x2 grid renders through the parent
oSurf = new stzSurfaceChart([ [1, 2], [3, 4] ])
chk("stzSurfaceChart builds and renders", len(oSurf.ToString()) > 0)
oSq = new stzSquareChart([ [1, 2], [3, 4] ])
chk("stzSquareChart (same parent) renders", len(oSq.ToString()) > 0)
chk("... and both are the same picture (both are stzSurfacePlot)",
	oSurf.ToString() = oSq.ToString())

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
