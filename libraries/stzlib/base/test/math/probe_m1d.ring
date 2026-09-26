# PROBE, not a gate: the :BoxPlot and :Surface figures born standalone.
load "../../stzBase.ring"
load "math_scenes.ring"

for i = 21 to 26
	t0 = StzEngineWatchTimestampMs()
	oF = StzMathFigScene(i)
	oF.Layout()
	? "== scene " + i + "  [" + (StzEngineWatchTimestampMs() - t0) + " ms]"
	? "   " + oF.Why()
	? "   feasible " + oF.IsSolved() + "  unknowns " + oF.Diagram().NumberOfUnknowns() + "  constraints " + oF.Diagram().NumberOfConstraints()
	aV = oF.Violations()
	for k = 1 to len(aV)  ? "   ! " + StzLeft(aV[k][:message], 150)  next
	if oF.Kind() = "boxplot"  ? oF.Text()  ok
	oF.ToPNG("probe_" + i + ".png")
next
