# PLOT PARITY -- the engine renderer against the Ring one it was ported from.
#
# -- WHY THIS SUITE EXISTS, AND WHAT IT WOULD HAVE CAUGHT --
#
# The plot renderers moved into the engine so that every language over it gets a
# picture, not a pile of layout numbers. A port like that has exactly one
# acceptable standard: THE SAME CHARACTERS. A plot IS its characters -- a bar one
# row short or a label left-aligned instead of right is a different plot, and
# nothing about it will raise an error.
#
# That last part is the danger, and it already bit. stzHBarPlot inherits from
# stzBarPlot, so when stzBarPlot.ToString() moved to the engine, the horizontal
# class silently inherited the VERTICAL renderer and drew horizontal data as
# vertical bars. Nothing errored. All 73 plot examples still "passed", because
# they only check that a script runs. The subclass guard passed too, because it
# never compared a picture.
#
# So this suite compares ToString() against ToStringInRing() -- the original Ring
# renderer, kept for exactly this purpose -- for every plot class and several
# data shapes. It is the only check that can tell a correct port from a
# plausible one.
#
# Everything below is run for real against the built library.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("The vertical bar plot renders identically in the engine")
	# the shapes that exercise different layout paths: equal-width labels, labels
	# wider than the bar, and values whose ratio forces the ceil rounding
	Then("basic three bars", PpSameBar([ [ "A", 3 ], [ "B", 7 ], [ "C", 5 ] ]), TRUE)
	Then("...labels wider than the bars",
	     PpSameBar([ [ "alpha", 12 ], [ "b", 4 ], [ "gamma", 9 ], [ "d", 1 ] ]), TRUE)
	Then("...a ratio that rounds badly if you round instead of ceil",
	     PpSameBar([ [ "X", 100 ], [ "Y", 300 ] ]), TRUE)
	Then("...a single bar", PpSameBar([ [ "only", 5 ] ]), TRUE)
	Then("...and a value so small it would vanish if floored",
	     PpSameBar([ [ "tiny", 1 ], [ "huge", 1000 ] ]), TRUE)
EndScenario()

Scenario("...and so does the HORIZONTAL one, which is a different picture entirely")
	# THE REGRESSION THIS PINS. A horizontal plot is not the vertical one
	# transposed: different bar glyph, labels down the left and RIGHT-ALIGNED
	# against the axis, one row per bar, different axis columns. Inheriting the
	# vertical ToString() produced a vertical plot from horizontal data.
	Then("basic three bars", PpSameHBar([ [ "A", 3 ], [ "B", 7 ], [ "C", 5 ] ]), TRUE)
	Then("...labels of different widths, right-aligned against the axis",
	     PpSameHBar([ [ "alpha", 12 ], [ "b", 4 ], [ "gamma", 9 ] ]), TRUE)
	Then("...an extreme ratio", PpSameHBar([ [ "X", 1 ], [ "Y", 1000 ] ]), TRUE)
	Then("...and a single bar", PpSameHBar([ [ "one", 7 ] ]), TRUE)

	# and the two renderers must not agree with EACH OTHER -- if a horizontal plot
	# ever equals the vertical plot of the same data, the inheritance bug is back
	oV = new stzBarPlot([ [ "A", 3 ], [ "B", 7 ], [ "C", 5 ] ])
	oH = new stzHBarPlot([ [ "A", 3 ], [ "B", 7 ], [ "C", 5 ] ])
	Then("a horizontal plot is NOT a vertical plot", oV.ToString() = oH.ToString(), FALSE)
EndScenario()

Scenario("...with the options on, which change the layout rather than decorate it")
	# values and percentages widen the column that holds them, so they move
	# everything to their right -- a place a port can easily get wrong
	oA = new stzBarPlot([ [ "A", 100 ], [ "B", 300 ] ])
	oA.SetValues(TRUE)
	Then("values shown", oA.ToString() = oA.ToStringInRing(), TRUE)

	oB = new stzBarPlot([ [ "A", 100 ], [ "B", 300 ] ])
	oB.SetPercent(TRUE)
	Then("percentages shown", oB.ToString() = oB.ToStringInRing(), TRUE)

	oC = new stzHBarPlot([ [ "A", 3 ], [ "B", 7 ] ])
	oC.SetValues(TRUE)
	Then("...and on the horizontal plot too", oC.ToString() = oC.ToStringInRing(), TRUE)
EndScenario()

Summary()

#-- helpers (Pp-prefixed) ------------------------------------------------------

func PpSameBar(paData)
	_ppO_ = new stzBarPlot(paData)
	return _ppO_.ToString() = _ppO_.ToStringInRing()

func PpSameHBar(paData)
	_ppO2_ = new stzHBarPlot(paData)
	return _ppO2_.ToString() = _ppO2_.ToStringInRing()
