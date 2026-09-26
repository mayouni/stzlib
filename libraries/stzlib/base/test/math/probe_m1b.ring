# PROBE, not a gate: the :NumberLine and :Fraction figures born standalone.
load "../../stzBase.ring"

acK = [ "numberline08", "numberline09", "fraction10", "fraction11", "fraction12" ]
for i = 1 to 5
	t0 = StzEngineWatchTimestampMs()
	if i = 1  oF = StzMathFigureQ(:NumberLine, [ :on = [ -5, 10 ], :points = [ 3, -2, 7.5, [ 0.5, "half" ] ], :jumps = [ [ 2, 5 ] ], :label = "the numbers from -5 to 10, and 2 + 3" ])
	but i = 2  oF = StzMathFigureQ(:NumberLine, [ :on = [ 0, 12 ], :jumps = [ [ 9, 4 ] ], :step = 1, :label = "9 - 5 = 4" ])
	but i = 3  oF = StzMathFigureQ(:Fraction, [ :of = [ 3, 4 ], :label = "three of four" ])
	but i = 4  oF = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 4 ], [ 2, 3 ], [ 2, 4 ], [ 1, 2 ] ], :label = "which is more?" ])
	else       oF = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 8 ], [ 1, 4 ] ], :as = :disc, :label = "three of eight, one of four" ])  ok
	oF.Layout()
	? "== " + acK[i] + "  [" + (StzEngineWatchTimestampMs() - t0) + " ms]"
	? "   " + oF.Why()
	? "   feasible " + oF.IsSolved() + "  unknowns " + oF.Diagram().NumberOfUnknowns() + "  constraints " + oF.Diagram().NumberOfConstraints()
	aV = oF.Violations()
	for k = 1 to len(aV)  ? "   ! " + StzLeft(aV[k][:message], 150)  next
	oF.ToPNG("probe_" + acK[i] + ".png")
next
