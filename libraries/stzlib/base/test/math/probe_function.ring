# PROBE, not a gate: the :Function figure born standalone, seconds per run.
load "../../stzBase.ring"

t0 = StzEngineWatchTimestampMs()
oF = StzMathFigureQ(:Function, [ :f = "sin(x) / x", :on = [ -12, 12 ],
                                  :mark = [ :zeros, :extrema ], :label = "y = sin(x) / x" ])
? "built in " + (StzEngineWatchTimestampMs() - t0) + " ms"
t1 = StzEngineWatchTimestampMs()
oF.Layout()
? "solved in " + (StzEngineWatchTimestampMs() - t1) + " ms  (" + oF.LayoutMs() + " ms by the diagram)"
? oF.Why()
? "feasible: " + oF.IsSolved()
oD = oF.Diagram()
? "unknowns " + oD.NumberOfUnknowns() + "  constraints " + oD.NumberOfConstraints() + "  rounds " + oD.Rounds()
aV = oF.Violations()
for k = 1 to len(aV)  ? "   ! " + aV[k][:message]  next
? "marks: " + @@(oF.Marks())
? "window: " + @@(oF.Window())
cSvg = oF.ToSVG()
? "svg bytes " + len(cSvg)
write("probe_function.svg", cSvg)
? "written probe_function.svg"
