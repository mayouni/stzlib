# PROBE M4c (2/2) -- the residual-versus-fit figure and the coded table on
# R's deaths table, their rules, their witnesses, their refusals.
load "../../stzBase.ring"
load "math_scenes.ring"

for i = 33 to 35
	oF = StzMathFigScene(i)
	oF.Layout()
	? "== scene " + i + ": " + oF.Why()
	aV = oF.Violations()
	? "   violations " + len(aV)
	for k = 1 to len(aV)  ? "      " + aV[k][:rule] + ": " + aV[k][:message]  next
	? "   findings under the check: " + len(StzCheckPictures([ [ "scene", oF.Diagram() ] ]).Findings())
	if i >= 34  ? oF.Text()  ok
next

# the deaths residuals: 0 2 0 / 0 -2 0 / 0 -5 2 / 5 0 0 / 0 3 0 -> fourth-spread 1
oRp = StzMathFigScene33()
oRp.Layout()
oSb = oRp.Diagram().Substance()
? "residual plot: scale " + oSb.DataOf("fr", "scale") + ", points " + oSb.DataOf("fr", "points") + ", outside " + oSb.DataOf("fr", "outside") + ", far out " + oSb.DataOf("fr", "farout")
oRp.SetDatum("p8", "fit", 99)
aF = StzCheckPictures([ [ "witness", oRp.Diagram() ] ]).Findings()
? "tampered fit -> " + len(aF) + " finding(s)"
for k = 1 to len(aF)  ? "   " + aF[k][:rule] + ": " + aF[k][:message]  next

oC = StzMathFigScene34()
oC.Layout()
? "coded: " + oC.Why()
oS = oC.Diagram().Substance()
? "cell (3,2) glyph '" + oS.LabelOf("z3_2") + "' band " + oS.DataOf("z3_2", "band") + "; cell (4,1) '" + oS.LabelOf("z4_1") + "'; cell (1,2) '" + oS.LabelOf("z1_2") + "'"
oC2 = StzMathFigScene34()
oC2.Layout()
oC2.SetDatum("z3_2", "res", 0)
aF2 = StzCheckPictures([ [ "witness", oC2.Diagram() ] ]).Findings()
? "tampered residual under a far-out glyph -> " + len(aF2) + " finding(s)"
for k = 1 to len(aF2)  ? "   " + aF2[k][:rule] + ": " + aF2[k][:message]  next

for cCase in [ "ragged", "glyphs", "names" ]
	try
		if cCase = "ragged"  StzMathFigureQ(:CodedTable, [ :of = [ [ 1, 2 ], [ 3 ] ] ])
		but cCase = "glyphs"  StzMathFigureQ(:CodedTable, [ :of = [ [ 1, 2 ], [ 3, 4 ] ], :glyphs = :Emoji ])
		but cCase = "names"  StzMathFigureQ(:ResidualPlot, [ :of = [ [ 1, 2 ], [ 3, 4 ] ], :names = [ [ "a" ], [ "b", "c" ] ] ])
		ok
		? cCase + ": NOT refused"
	catch
		? cCase + " refused: " + StzLeft(cCatchError, 100)
	done
next
