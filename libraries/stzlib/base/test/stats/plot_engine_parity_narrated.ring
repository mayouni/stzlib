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

Scenario("A histogram actually SHOWS its bin labels")
	# THE DEFECT THIS PINS. The histogram reserves two label rows under its axis --
	# bin starts on one, bin ends on the next -- and used to draw NOTHING in them
	# for any data below 1000, because CompactForm() had no else branch and
	# returned "" for every value it could not abbreviate. Two empty rows, on every
	# small histogram, silently.
	#
	# Fixing that exposed the other half: the layout MEASURED labels with
	# RoundN(edge, 1) while the drawer wrote CompactForm(edge), so the reserved
	# room said "3.4" and the ink said "3.40000000004" and the labels collided.
	# One formatter now serves bins, layout and drawer alike.
	oH = new stzHistogram([ 1, 2, 2, 3, 3, 3, 4, 4, 5 ])
	aRows = PpRows(oH.ToString())
	nR = len(aRows)

	Then("the last two rows are the label rows, and they are NOT empty",
	     PpTrim(aRows[nR-1]) != "" and PpTrim(aRows[nR]) != "", TRUE)
	Then("...the bin starts are readable", PpHas(aRows[nR-1], "1.8"), TRUE)
	Then("...and so are the bin ends", PpHas(aRows[nR], "5"), TRUE)

	# no float artefact leaks into a label: an edge of 3.4000000000000004 must
	# print as 3.4, which is what rounding before compacting is for
	Then("no floating-point noise in a label",
	     PpHas(aRows[nR-1], "3.40000") or PpHas(aRows[nR], "3.40000"), FALSE)

	# and a LARGE histogram still compacts, which is what CompactForm is for
	oL = new stzHistogram([ 1200, 2500, 2600, 3100, 3300, 3400, 4800, 4900, 5000 ])
	aBig = PpRows(oL.ToString())
	Then("a large histogram still abbreviates its edges",
	     PpHas(aBig[len(aBig)-1], "K"), TRUE)
EndScenario()

Scenario("...and CompactForm returns a number too small to abbreviate as ITSELF")
	# The root cause, pinned at its source: the chain had no else, so anything
	# under 1000 compacted to nothing. KForm() and MForm() beside it always ended
	# with the number itself; this one had simply lost that branch.
	Then("12.25 compacts to itself", StzNumberQ(12.25).CompactForm() != "", TRUE)
	Then("999 compacts to itself", StzNumberQ(999).CompactForm(), "999")
	Then("1000 becomes 1K", StzNumberQ(1000).CompactForm(), "1K")
	Then("1500 becomes 1.5K", StzNumberQ(1500).CompactForm(), "1.5K")
	Then("1234567 becomes 1.2M", StzNumberQ(1234567).CompactForm(), "1.2M")

	# the boundary that also fell through: `> 1_000_000_000` skipped EXACTLY one
	# billion, where every other boundary in the chain is inclusive
	Then("exactly one billion becomes 1B", StzNumberQ(1000000000).CompactForm(), "1B")
	Then("...and the value the old test used still reads 1.3B",
	     StzNumberQ(1290800280).CompactForm(), "1.3B")
EndScenario()

Summary()

#-- helpers (Pp-prefixed) ------------------------------------------------------

func PpSameBar(paData)
	_ppO_ = new stzBarPlot(paData)
	return _ppO_.ToString() = _ppO_.ToStringInRing()

func PpSameHBar(paData)
	_ppO2_ = new stzHBarPlot(paData)
	return _ppO2_.ToString() = _ppO2_.ToStringInRing()

func PpRows(cText)
	return @split(cText, nl)

func PpTrim(cLine)
	return trim(cLine)

func PpHas(cLine, cNeedle)
	return StzFindFirst(cNeedle, cLine) > 0
