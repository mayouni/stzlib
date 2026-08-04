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

Scenario("The histogram renders identically in the engine")
	# binning and drawing both live in plot.zig now, so a host gets a histogram
	# rather than a pile of edges it has to draw itself
	Then("small integers", PpSameHist([ 1, 2, 2, 3, 3, 3, 4, 4, 5 ]), TRUE)
	Then("...large values, whose labels compact", 
	     PpSameHist([ 1200, 2500, 2600, 3100, 3300, 3400, 4800, 4900, 5000 ]), TRUE)
	Then("...a sample with NO SPREAD at all", PpSameHist([ 5, 5, 5, 5 ]), TRUE)
	Then("...and two values far apart", PpSameHist([ 1, 100 ]), TRUE)

	# THE CONFIGURATIONS THE ENGINE DOES NOT COVER fall back to the Ring renderer
	# rather than drawing something close. ShowStats needs the RAW SAMPLES to report
	# a mean, and the engine renderer is handed bins; hiding the axis triggers a
	# post-processing step that strips a leading line.
	oS = new stzHistogram([ 1, 2, 2, 3, 3, 3 ])
	oS.SetStats(TRUE)
	Then("with stats shown, the fallback still matches itself",
	     oS.ToString() = oS.ToStringInRing(), TRUE)
	Then("...and the stats really are appended", PpHas(oS.ToString(), "Mean:"), TRUE)
EndScenario()

Scenario("The GROUPED bar plot renders identically, legend and all")
	# a grouped chart is unreadable without a legend -- three shades of block mean
	# nothing until something says which is which -- and the legend SETS THE WIDTH,
	# so it cannot be bolted on by a host after the layout is decided
	Then("one series", PpSameMBar([ :Sales = [ :Q1=25, :Q2=35 ] ]), TRUE)
	Then("...two series", PpSameMBar([ :Sales = [ :Q1=25, :Q2=35 ], :Costs = [ :Q1=15, :Q2=20 ] ]), TRUE)
	Then("...three with short names, where the BARS are wider",
	     PpSameMBar([ :S = [ :Q1=25, :Q2=35, :Q3=30 ], :C = [ :Q1=15, :Q2=20, :Q3=18 ],
	                  :P = [ :Q1=10, :Q2=15, :Q3=12 ] ]), TRUE)
	Then("...three with long names, where the LEGEND is wider",
	     PpSameMBar([ :Sales = [ :Q1=25, :Q2=35, :Q3=30 ], :Costs = [ :Q1=15, :Q2=20, :Q3=18 ],
	                  :Profit = [ :Q1=10, :Q2=15, :Q3=12 ] ]), TRUE)

	# a category whose LABEL is wider than its bars widens the element, and the bars
	# must then sit CENTRED in it -- left-aligned they drift off their own tick
	Then("...and a label wider than the group it belongs to",
	     PpSameMBar([ :A = [ :VeryLongCategoryName=5, :B=9 ] ]), TRUE)
EndScenario()

Scenario("...and every CHART SUBCLASS renders through the same engine path")
	# THE AXIS THE REGRESSION CAME IN ON. stzHBarPlot inherited a base ToString()
	# that had moved and silently drew the wrong picture. These subclasses inherit
	# their renderers too, so each is checked against its own Ring reference rather
	# than assumed to be fine.
	Then("stzVBarChart matches", PpSameSub("stzVBarChart"), TRUE)
	Then("stzBarChart matches", PpSameSub("stzBarChart"), TRUE)
	Then("stzVBarPlot matches", PpSameSub("stzVBarPlot"), TRUE)
	Then("stzHBarChart matches", PpSameSub("stzHBarChart"), TRUE)
	Then("stzMBarChart matches", PpSameSubM("stzMBarChart"), TRUE)
	Then("stzMultiBarChart matches", PpSameSubM("stzMultiBarChart"), TRUE)
	Then("stzMultiBarPlot matches", PpSameSubM("stzMultiBarPlot"), TRUE)
EndScenario()

Scenario("A scatter plot renders in its DEFAULT configuration")
	# THE DEFECT THIS PINS. stzScatterPlot crashed outright with its axes on --
	# "Can't create the stzList object! paList must be a list" -- so its primary
	# presentation never worked. Every one of the plot examples calls
	# WithoutVHAxis() first, which is not a style choice: it was the only shape that
	# ran.
	#
	# The cause was a Ring parsing trap, three times over:
	#
	#     new stzList(aList).Sorted()
	#
	# binds as new stzList( aList.Sorted() ), so Sorted() is called on the RAW LIST
	# and its result -- not a list -- is handed to the constructor, which rejects
	# it. The object has to be built before a method is called on it.
	aD = [ [1,1], [2,5], [2,4], [3,2], [3,4], [4,5], [4,6], [5,3] ]
	Then("the default configuration renders at all", PpScatterRuns(aD, FALSE), TRUE)
	Then("...and so does the axis-free one the examples used", PpScatterRuns(aD, TRUE), TRUE)

	# with axes on it draws what axes are for: tick marks and value labels
	oS = new stzScatterPlot(aD)
	cOut = oS.ToString()
	Then("...the value axis is labelled", PpHas(cOut, "6"), TRUE)
	Then("...there are tick marks", PpHas(cOut, "┬") or PpHas(cOut, "┤"), TRUE)
	Then("...and the points are drawn", PpHas(cOut, "●"), TRUE)

	# EACH AXIS LETTER APPEARS ONCE. Two separate blocks used to place each one --
	# an X row prepended twice with different indentation, and " Y" appended to the
	# axis and then again by the replacement that extends it. Nothing errored; the
	# plot simply carried two of each label.
	Then("the X letter appears exactly once", PpCountOf(cOut, "X"), 1)
	Then("...and the Y letter exactly once", PpCountOf(cOut, "Y"), 1)

	# THE ARROW STANDS OVER ITS OWN AXIS. It did not: Ring's bare split() trims the
	# leading whitespace of the FIRST piece, and the canvas's first row is the one
	# carrying the vertical arrow -- so decomposing the plot into lines pulled the
	# arrow back to column 1 while every row beneath it kept its indent. The drawing
	# was correct all along; the damage happened when it was taken apart.
	aRows = PpRows(cOut)
	Then("the X letter, the arrow and the axis share one column",
	     PpIndentOf(aRows[1]) = PpIndentOf(aRows[2]) and
	     PpIndentOf(aRows[2]) = PpIndentOf(aRows[3]), TRUE)
	Then("...and it is the column the ticks sit in",
	     PpIndentOf(aRows[2]) + 1 = PpFindCol(aRows[4], "┤"), TRUE)
EndScenario()

Scenario("The SCATTER plot renders identically in the engine")
	# the axis width is decided by the widest value label, so "10" pushes the whole
	# plot right where "1" does not -- and the arrow, the letter and the ticks all
	# have to agree about the column that produces
	Then("the documented example",
	     PpSameScatter([ [1,1], [2,5], [2,4], [3,2], [3,4], [4,5], [4,6], [5,3] ]), TRUE)
	Then("...two-digit labels widen the axis",
	     PpSameScatter([ [1,10], [2,20], [3,30] ]), TRUE)
	Then("...non-integers round to one decimal",
	     PpSameScatter([ [1,1.5], [2,2.5], [3,3.25] ]), TRUE)

	# A DEGENERATE AXIS used to divide by zero -- eight inline copies of the same
	# mapping, each dividing by (max - min), so a single point crashed the renderer
	# outright. The mapping is one guarded method now, and the two rules differ on
	# purpose: a lone POINT centres in the space it has, while its TICK stays on the
	# axis where a reader looks for it.
	Then("a single point renders at all", PpSameScatter([ [5,5] ]), TRUE)
	Then("...no horizontal spread", PpSameScatter([ [1,1], [1,2], [1,3] ]), TRUE)
	Then("...and no vertical spread", PpSameScatter([ [1,7], [2,7], [3,7] ]), TRUE)

	# THE AXIS-FREE SHAPE IS THE COMMON ONE -- every plot example calls
	# WithoutVHAxis(), originally because it was the only shape that ran. It drops
	# the top row, which exists only to hold an arrow there is no longer any axis
	# for, so it is a different picture and not merely the same one with less ink.
	oN = new stzScatterPlot([ [1,1], [2,5], [2,4], [3,2], [3,4], [4,5], [4,6], [5,3] ])
	oN.WithoutVHAxis()
	Then("...and so does the axis-free shape", oN.ToString() = oN.ToStringInRing(), TRUE)

	# the subclass rides the same path
	oC = new stzScatterChart([ [1,1], [2,3], [3,2] ])
	Then("stzScatterChart matches too", oC.ToString() = oC.ToStringInRing(), TRUE)
EndScenario()

Scenario("The surface plot is a treemap, and the engine cuts the same tiles")

	# THE LAST PLOT TO MOVE, and the one with real ALGORITHM behind it rather than
	# arithmetic: the values are sorted largest-first and the frame is cut recursively
	# in proportion to them, so a wrong split does not shift a label by a column -- it
	# rearranges the whole picture.
	#
	# All three subclasses -- stzSurfaceChart, stzSquareChart, stzSquarePlot -- inherit
	# ToString(), so they move together. That is the safe direction, and it is checked
	# below rather than assumed: stzHBarPlot inherited a ToString() that had moved to
	# the VERTICAL renderer and drew horizontal data vertically for a whole commit,
	# raising nothing.

	Given("a surface plot of four departments")
	When("the engine renders it instead of Ring")

	Then("the picture is identical", PpSameSurf([ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ]), TRUE)

	# THE FOUR LAYOUT ARMS. One tile fills the frame; two, three and four are placed by
	# hand; five and above halve the list and recurse. Each arm is a different code
	# path, so each needs its own case -- four tiles passing proves nothing about six.
	Then("one tile fills the frame", PpSameSurf([ :Only = 99 ]), TRUE)
	Then("...two tiles split the longer side", PpSameSurf([ :Alpha = 70, :Beta = 30 ]), TRUE)
	Then("...three put the largest alone", PpSameSurf([ :Alpha = 50, :Beta = 30, :Gamma = 20 ]), TRUE)
	Then("...four make a 2x2 grid", PpSameSurf([ :A = 40, :B = 30, :C = 20, :D = 10 ]), TRUE)
	Then("...five recurse", PpSameSurf([ :A = 40, :B = 25, :C = 15, :D = 12, :E = 8 ]), TRUE)
	Then("...six recurse", PpSameSurf([ :Aa = 30, :Bb = 22, :Cc = 18, :Dd = 14, :Ee = 10, :Ff = 6 ]), TRUE)
	Then("...and nine recurse twice", PpSameSurf([ :A = 30, :B = 22, :C = 18, :D = 14, :E = 10, :F = 6, :G = 4, :H = 3, :I = 2 ]), TRUE)

	# A TIE IS A SORT DECISION, and the two implementations have to break it the same
	# way or two tiles swap places. The engine repeats the Ring walk exactly rather
	# than calling a library sort, for this reason alone.
	Then("equal values keep their order", PpSameSurf([ :A = 25, :B = 25, :C = 25, :D = 25 ]), TRUE)
	Then("...and one value can swamp the rest", PpSameSurf([ :Huge = 990, :Tiny = 5, :Smaller = 3, :Least = 2 ]), TRUE)

	# THE BORDER JUNCTIONS are drawn in four passes, and the third READS the canvas it
	# is writing -- it sees its own earlier upgrades. That makes the order part of the
	# output, not an implementation detail, which is why the port replays the passes in
	# sequence instead of computing each cell from the tile list.
	Then("the junctions are drawn", PpSurfJunctions([ :A = 40, :B = 25, :C = 15, :D = 12, :E = 8 ]) > 0, TRUE)
	Then("...and a lone tile has none to draw", PpSurfJunctions([ :Only = 99 ]), 0)
	Then("...and the frame is closed", PpSurfClosed([ :A = 40, :B = 25, :C = 15, :D = 12, :E = 8 ]), TRUE)

	Given("the same plot with its numbers switched on")

	Then("values match", PpSameSurfOpt([ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ], :Values), TRUE)
	Then("...percentages match", PpSameSurfOpt([ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ], :Percent), TRUE)
	Then("...and both together match", PpSameSurfOpt([ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ], :Both), TRUE)

	# A VALUE PRINTS BARE WHEN IT IS WHOLE and to one decimal otherwise -- 45 and 45.5,
	# never 45.0. The percentage follows the same rule, which is NOT what the bar plots
	# do (they force a decimal on percentages), so the two cannot share a formatter.
	Then("fractions round to one place", PpSameSurfOpt([ :Sales = 45.5, :Marketing = 25.25, :Dev = 20, :Support = 9.25 ], :Both), TRUE)

	Given("the plot stripped of its furniture")

	Then("no borders matches", PpSameSurfNo([ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ], :Borders), TRUE)
	Then("...no labels matches", PpSameSurfNo([ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ], :Labels), TRUE)

	# WITHOUT BORDERS the rows are still padded to full width -- twelve rows of forty
	# columns, mostly blank. A trimmed row and a padded row are different strings, and
	# this compares strings.
	Then("...and the rows stay padded", PpSurfWidth([ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ]), 40)

	Given("labels that do not fit")

	# A LABEL TOO LONG IS CUT AND MARKED with a full stop, and the cut is measured in
	# CODEPOINTS. Ring's own renderer indexes the drawn line by BYTE, so it would tear
	# a multibyte label apart; the engine walks codepoints. They agree on everything
	# ASCII, which is everything a hash list can carry here -- its keys are folded.
	Then("an over-long label is truncated", PpSameSurf([ :InternationalOperations = 45, :Marketing = 25, :Dev = 20, :Support = 10 ]), TRUE)
	Then("...even one longer than the frame", PpSameSurf([ :AVeryLongDepartmentNameIndeedThatOverflows = 45, :B = 25 ]), TRUE)

	Given("the plot resized")

	Then("a wider canvas matches", PpSameSurfSize([ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ], 60, 20), TRUE)
	Then("...the maximum matches", PpSameSurfSize([ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ], 120, 30), TRUE)
	Then("...and the minimum matches", PpSameSurfSize([ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ], 40, 12), TRUE)

	Given("the three subclasses")

	Then("stzSurfaceChart matches", PpSameSubSurf(:stzSurfaceChart), TRUE)
	Then("...stzSquareChart matches", PpSameSubSurf(:stzSquareChart), TRUE)
	Then("...and stzSquarePlot matches", PpSameSubSurf(:stzSquarePlot), TRUE)
EndScenario()

Scenario("A plot drawn with the caller's own characters is still the same plot")

	# -- THE GAP THIS SUITE HAD, AND WHAT FELL THROUGH IT --
	#
	# Every scene above compares the engine against the Ring renderer on DEFAULT
	# settings. None of them ever called SetBarChar. So when the renderers moved to
	# the engine and the chosen characters were left behind on the Ring side, the
	# guard went on passing: both implementations drew █, one because it was told to
	# and one because it knew nothing else.
	#
	# Six setters across four classes had quietly become no-ops -- SetBarChar,
	# SetTopChar, SetAxisChars, SetFinalBarChar, SetSeriesChars, SetPointChar. Nothing
	# raised. The examples that demonstrate them printed the default glyph next to a
	# comment promising a custom one, and 04_pr.ring even carried a #TODO wondering
	# why its top character never appeared.
	#
	# So each case below sets a character AND checks two things: that the picture
	# still matches the Ring renderer, and that the chosen character is actually in
	# it. The second half is the one that matters -- two renderers agreeing on the
	# wrong glyph is exactly the state this suite was already in.

	Given("a bar plot told to draw with X")
	When("the engine renders it")

	Then("the pictures match", PpCharSame(:VBar, :Bar, "X"), TRUE)
	Then("...and an X is drawn", PpCharDrawn(:VBar, :Bar, "X"), TRUE)

	Given("the other characters a bar plot lets you choose")

	Then("a top character matches", PpCharSame(:VBar, :Top, "*"), TRUE)
	Then("...and is drawn", PpCharDrawn(:VBar, :Top, "*"), TRUE)
	Then("axis characters match", PpCharSame(:VBar, :Axis, "!"), TRUE)
	Then("...and are drawn", PpCharDrawn(:VBar, :Axis, "!"), TRUE)

	Given("the same for every other plot in the family")

	Then("the horizontal bar matches", PpCharSame(:HBar, :Bar, "="), TRUE)
	Then("...and draws its character", PpCharDrawn(:HBar, :Bar, "="), TRUE)
	Then("the histogram matches", PpCharSame(:Hist, :Bar, "#"), TRUE)
	Then("...and draws its character", PpCharDrawn(:Hist, :Bar, "#"), TRUE)
	Then("its final bar matches", PpCharSame(:Hist, :Final, "^"), TRUE)
	Then("...and is drawn", PpCharDrawn(:Hist, :Final, "^"), TRUE)
	Then("the scatter plot matches", PpCharSame(:Scatter, :Point, "+"), TRUE)
	Then("...and draws its points", PpCharDrawn(:Scatter, :Point, "+"), TRUE)
	Then("the multi-series plot matches", PpCharSame(:MBar, :Series, "@"), TRUE)
	Then("...and draws its series", PpCharDrawn(:MBar, :Series, "@"), TRUE)

	# THE NEGATIVE SIBLING: left alone, none of these plots draws any of those
	# characters. Without this, every assertion above would still pass against a
	# renderer that scattered "X" over the canvas for its own reasons.
	Then("an untouched plot draws no X", PpCharDrawn(:VBar, :None, "X"), FALSE)
	Then("...nor the scatter a +", PpCharDrawn(:Scatter, :None, "+"), FALSE)
	Then("...nor the histogram a #", PpCharDrawn(:Hist, :None, "#"), FALSE)
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

func PpSameHist(paData)
	_ppH_ = new stzHistogram(paData)
	return _ppH_.ToString() = _ppH_.ToStringInRing()

func PpSameMBar(paData)
	_ppM_ = new stzMultiBarPlot(paData)
	return _ppM_.ToString() = _ppM_.ToStringInRing()

# a single-series bar subclass, by name
func PpSameSub(cClass)
	_ppD_ = [ [ "A", 3 ], [ "B", 7 ], [ "C", 5 ] ]
	eval("_ppS_ = new " + cClass + "(_ppD_)")
	return _ppS_.ToString() = _ppS_.ToStringInRing()

# a multi-series subclass, by name
func PpSameSubM(cClass)
	_ppD2_ = [ :Sales = [ :Q1=25, :Q2=35 ], :Costs = [ :Q1=15, :Q2=20 ] ]
	eval("_ppS2_ = new " + cClass + "(_ppD2_)")
	return _ppS2_.ToString() = _ppS2_.ToStringInRing()

func PpScatterRuns(paData, bNoAxes)
	_ppR_ = TRUE
	try
		_ppSc_ = new stzScatterPlot(paData)
		if bNoAxes
			_ppSc_.WithoutVHAxis()
		ok
		_ppT_ = _ppSc_.ToString()
		if NOT isString(_ppT_) or _ppT_ = ""
			_ppR_ = FALSE
		ok
	catch
		_ppR_ = FALSE
	done
	return _ppR_

func PpCountOf(cText, cNeedle)
	return len(StzFind(cNeedle, cText))

# how many leading spaces a line has
func PpIndentOf(cLine)
	_ppI_ = 0
	_ppN_ = len(cLine)
	for _ppK_ = 1 to _ppN_
		if cLine[_ppK_] != " "
			exit
		ok
		_ppI_++
	next
	return _ppI_

func PpFindCol(cLine, cNeedle)
	return StzFindFirst(cNeedle, cLine)

func PpSameScatter(paData)
	_ppSp_ = new stzScatterPlot(paData)
	return _ppSp_.ToString() = _ppSp_.ToStringInRing()

func PpSameSurf(paData)
	_ppSf_ = new stzSurfacePlot(paData)
	return _ppSf_.ToString() = _ppSf_.ToStringInRing()

func PpSurfOf(paData)
	_ppSf2_ = new stzSurfacePlot(paData)
	return _ppSf2_.ToString()

# every row the same width, and the four corners in place
func PpSurfClosed(paData)
	_ppSf3_ = new stzSurfacePlot(paData)
	_ppRows_ = PpRows(_ppSf3_.ToString())
	_ppN_ = len(_ppRows_)
	if _ppN_ = 0
		return FALSE
	ok
	_ppW_ = StzLen(_ppRows_[1])
	for _ppI_ = 1 to _ppN_
		if StzLen(_ppRows_[_ppI_]) != _ppW_
			return FALSE
		ok
	next
	return PpHas(_ppRows_[1], char(226) + char(149) + char(173)) and
	       PpHas(_ppRows_[_ppN_], char(226) + char(149) + char(176))

func PpSurfWidth(paData)
	_ppSf4_ = new stzSurfacePlot(paData)
	_ppSf4_.WithoutBorders()
	_ppRw_ = PpRows(_ppSf4_.ToString())
	if len(_ppRw_) = 0
		return 0
	ok
	return StzLen(_ppRw_[1])

func PpSameSurfOpt(paData, cWhat)
	_ppSf5_ = new stzSurfacePlot(paData)
	if cWhat = :Values or cWhat = :Both
		_ppSf5_.AddValues()
	ok
	if cWhat = :Percent or cWhat = :Both
		_ppSf5_.AddPercent()
	ok
	return _ppSf5_.ToString() = _ppSf5_.ToStringInRing()

func PpSameSurfNo(paData, cWhat)
	_ppSf6_ = new stzSurfacePlot(paData)
	if cWhat = :Borders
		_ppSf6_.WithoutBorders()
	else
		_ppSf6_.WithoutLabels()
		_ppSf6_.AddValues()
	ok
	return _ppSf6_.ToString() = _ppSf6_.ToStringInRing()

func PpSameSurfSize(paData, nW, nH)
	_ppSf7_ = new stzSurfacePlot(paData)
	_ppSf7_.SetSize(nW, nH)
	return _ppSf7_.ToString() = _ppSf7_.ToStringInRing()

func PpSameSubSurf(cClass)
	_ppD3_ = [ :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10 ]
	eval("_ppS3_ = new " + cClass + "(_ppD3_)")
	return _ppS3_.ToString() = _ppS3_.ToStringInRing()

# the glyphs only the junction passes can produce -- a plain frame has none of them
func PpSurfJunctions(paData)
	_ppSf8_ = new stzSurfacePlot(paData)
	_ppTxt_ = _ppSf8_.ToString()
	_ppC_ = 0
	_ppC_ += PpCountOf(_ppTxt_, char(226) + char(148) + char(172))
	_ppC_ += PpCountOf(_ppTxt_, char(226) + char(148) + char(180))
	_ppC_ += PpCountOf(_ppTxt_, char(226) + char(148) + char(156))
	_ppC_ += PpCountOf(_ppTxt_, char(226) + char(148) + char(164))
	_ppC_ += PpCountOf(_ppTxt_, char(226) + char(148) + char(188))
	return _ppC_

# Build one plot of the given kind, with one character set on it.
func PpCharPlot(cKind, cWhat, cChar)
	_ppP_ = NULL
	if cKind = :VBar
		_ppP_ = new stzVBarPlot([ :A = 5, :B = 8, :C = 3 ])
	but cKind = :HBar
		_ppP_ = new stzHBarPlot([ :A = 5, :B = 8, :C = 3 ])
	but cKind = :Hist
		_ppP_ = new stzHistogram([ 1, 2, 2, 3, 3, 3, 4, 4, 5 ])
	but cKind = :Scatter
		_ppP_ = new stzScatterPlot([ [1,2], [3,5], [6,9], [5,4] ])
	else
		_ppP_ = new stzMultiBarPlot([ :A = [ :Q1 = 5, :Q2 = 3 ], :B = [ :Q1 = 2, :Q2 = 4 ] ])
	ok

	if cWhat = :Bar
		_ppP_.SetBarChar(cChar)
	but cWhat = :Top
		_ppP_.SetTopChar(cChar)
	but cWhat = :Axis
		_ppP_.SetAxisChars(cChar, cChar)
	but cWhat = :Final
		_ppP_.SetFinalBarChar(cChar)
	but cWhat = :Point
		_ppP_.SetPointChar(cChar)
	but cWhat = :Series
		_ppP_.SetSeriesChars([ cChar, cChar ])
	ok
	return _ppP_

func PpCharSame(cKind, cWhat, cChar)
	_ppQ_ = PpCharPlot(cKind, cWhat, cChar)
	return _ppQ_.ToString() = _ppQ_.ToStringInRing()

func PpCharDrawn(cKind, cWhat, cChar)
	_ppR2_ = PpCharPlot(cKind, cWhat, cChar)
	return StzFindFirst(cChar, _ppR2_.ToString()) > 0
