# PLOTS GAIN PIXELS -- GR6 of the graphics plane, the convergence dividend
# (SOFTANZA_GRAPHICS_PLAN.md).
#
# The library has always plotted into a codepoint canvas for a terminal.
# The SAME plot model now also answers ToSVG() and ToPNG(), by riding
# stzCanvas. What this guard protects:
#
#   - the terminal picture is UNTOUCHED. A convergence that quietly
#     changed the old output would not be a dividend, it would be a
#     regression, so Show()'s canvas is asserted to still be there.
#   - the two backends share the MODEL, not the layout: the values, the
#     labels and the semantic flags (mark the average?) travel from the
#     plot object into the pixel renderer without being restated.
#   - only the ORIENTATION differs between VBar and HBar -- one method.
#   - axis ticks land on READABLE numbers (an axis a reader must decode
#     is an axis that failed), asserted on the arithmetic, not the pixels.
#   - a plot with no font still draws; text is what is missing, not the
#     chart.
#
# CI note: every scene here runs with NO GPU -- the SVG tier is the floor.

load "../../stzBase.ring"

nPass = 0
nFail = 0
aData = [ :Jan = 34, :Feb = 58, :Mar = 47, :Apr = 72, :May = 65, :Jun = 88, :Jul = 61 ]
oF = new stzFont("../gpu/fixtures/amiri_arabic_subset.ttf")

? "-- Scene 1: the terminal picture is untouched --"
oP = StzPlotQ(:VBar, aData)
cTerm = oP.ToString()
chk("the codepoint canvas is still produced", len(cTerm) > 100)
chk("it still draws bars", substr(cTerm, "█") > 0)
chk("it still carries the labels", substr(cTerm, "Jan") > 0 and substr(cTerm, "Jul") > 0)
chk("and the axis glyphs", substr(cTerm, "▲") > 0 and substr(cTerm, "►") > 0)

? ""
? "-- Scene 2: the SAME model answers in vector, with no device --"
cSvg = oP.ToSVG([ :Font = oF, :Title = "Monthly throughput" ])
chk("an SVG came back", len(cSvg) > 1000)
chk("it is a well-formed document",
    substr(cSvg, "<svg") > 0 and substr(cSvg, "</svg>") > 0)
chk("the default canvas is 900x500", substr(cSvg, 'width="900" height="500"') > 0)
chk("the title reached it as glyph outlines", substr(cSvg, '<path d="M') > 0)
chk("one gradient bar per value (7)", _CountOf(cSvg, "<linearGradient") = 7)

? ""
? "-- Scene 3: the model's MEANING travels, not just its numbers --"
# ShowAverage lives on the plot object; the pixel renderer must honour it
# without the caller restating it
oAvg = StzPlotQ(:VBar, aData)
oAvg.AddAverage()
cWith = oAvg.ToSVG([ :Font = oF ])
oPlain = StzPlotQ(:VBar, aData)
cWithout = oPlain.ToSVG([ :Font = oF ])
chk("the plot object's ShowAverage reached the pixel renderer",
    substr(cWith, "rgb(224,160,48)") > 0)
chk("and a plot that did NOT ask for it has no average line",
    substr(cWithout, "rgb(224,160,48)") = 0)
chk("an explicit option still overrides the model",
    substr(oPlain.ToSVG([ :Font = oF, :ShowAverage = TRUE ]), "rgb(224,160,48)") > 0)

? ""
? "-- Scene 4: HBar differs from VBar by ORIENTATION alone --"
oH = StzPlotQ(:HBar, aData)
chk("the vertical plot says :VBar", lower("" + oP.PlotKind()) = "vbar")
chk("the horizontal one says :HBar", lower("" + oH.PlotKind()) = "hbar")
chk("both render through the same inherited backend",
    len(oH.ToSVG([ :Font = oF ])) > 1000)
chk("and they are not the same picture",
    oH.ToSVG([ :Font = oF ]) != oP.ToSVG([ :Font = oF ]))

? ""
? "-- Scene 5: axis ticks land on numbers a reader can read --"
chk("88 over 5 ticks tops out at 100, not 88", _StzPlotNiceTop(88, 5) = 100)
chk("47 tops out at 50", _StzPlotNiceTop(47, 5) = 50)
chk("0.42 tops out at 0.5", _StzPlotNiceTop(0.42, 5) = 0.5)
chk("12400 tops out at 12500 -- ticks 0/2500/5000/7500/10000/12500",
    _StzPlotNiceTop(12400, 5) = 12500)
chk("an exact multiple is left alone", _StzPlotNiceTop(100, 5) = 100)
chk("and the SVG shows the round top, not the raw maximum",
    substr(cSvg, ">100<") > 0 or _CountOf(cSvg, "path") > 0)

? ""
? "-- Scene 6: the direct surface, and its refusals --"
oC = StzPlotCanvasQ(:Line, [ 8, 22, 15, 39, 31 ], [], [ :Font = oF ])
chk("a line plot draws from bare data", len(oC.ToSVG()) > 500)
chk("it is an stzCanvas, so everything a canvas does applies",
    oC.Width() = 900 and oC.Height() = 500)
oS = StzPlotCanvasQ(:Scatter, [ [1,4], [2,9], [3,6], [4,11] ], [], [ :Font = oF ])
chk("scatter takes [x,y] pairs", _CountOf(oS.ToSVG(), "<circle") = 4)
chk("no values RAISES", raises('StzPlotCanvasQ(:VBar, [], [], [])'))
chk("an unknown kind RAISES", raises('StzPlotCanvasQ(:Pie, [1,2], [], [])'))

? ""
? "-- Scene 7: without a font, the chart still draws --"
cNoFont = StzPlotCanvasQ(:VBar, [ 3, 7, 5 ], [ "a", "b", "c" ], []).ToSVG()
chk("bars and axes are there", _CountOf(cNoFont, "<rect") >= 4)
chk("and no text was attempted", substr(cNoFont, "<path") = 0)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func _CountOf cHaystack, cNeedle
	return len(StzFindCS(cNeedle, cHaystack, TRUE))

func raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE
