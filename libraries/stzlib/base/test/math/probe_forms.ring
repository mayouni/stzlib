# PROBE: the other forms and the edge cases of the :Function figure.
load "../../stzBase.ring"

ProbeForm("lissajous", [ :x = "cos(t)", :y = "sin(2*t)", :t = [ 0, 6.2832 ], :mark = [ 0, 1.5708 ], :label = "x = cos t, y = sin 2t" ])
ProbeForm("rose", [ :r = "cos(3*t)", :t = [ 0, 3.1416 ], :label = "r = cos 3t" ])
ProbeForm("pole", [ :f = "1 / x", :on = [ -2, 2 ], :window = [ -6, 6 ], :label = "y = 1 / x" ])
ProbeForm("cubic", [ :f = "x^3 - x", :on = [ -1.6, 1.6 ], :mark = [ :zeros, :extrema ], :tangent = 1.2, :label = "y = x^3 - x" ])
ProbeForm("tan", [ :f = "tan(x)", :on = [ -4.5, 4.5 ], :window = [ -4, 4 ], :mark = [ :zeros ], :label = "y = tan x" ])

# refusals, each at the line that made the mistake
acBad = [ "no f", "reversed range", "few samples", "unknown key", "bad mark", "tangent off range", "nowhere finite" ]
aSpecs = [ [ :on = [ 0, 1 ] ],
           [ :f = "x", :on = [ 1, 0 ] ],
           [ :f = "x", :on = [ 0, 1 ], :samples = 3 ],
           [ :f = "x", :on = [ 0, 1 ], :colour = "red" ],
           [ :f = "x", :on = [ 0, 1 ], :mark = [ :poles ] ],
           [ :f = "x", :on = [ 0, 1 ], :tangent = 5 ],
           [ :f = "sqrt(x)", :on = [ -3, -1 ] ] ]
for i = 1 to len(acBad)
	bRefused = FALSE
	cMsg = ""
	try
		o = StzMathFigureQ(:Function, aSpecs[i])
	catch
		bRefused = TRUE
		cMsg = cCatchError
	done
	? "refuse '" + acBad[i] + "': " + bRefused + "   " + StzLeft(StzReplace(cMsg, char(10), " "), 110)
next

func ProbeForm(cName, aSpec)
	t0 = StzEngineWatchTimestampMs()
	oF = StzMathFigureQ(:Function, aSpec)
	oF.Layout()
	? "== " + cName + "  [" + (StzEngineWatchTimestampMs() - t0) + " ms]"
	? "   " + oF.Why()
	? "   feasible " + oF.IsSolved() + "  unknowns " + oF.Diagram().NumberOfUnknowns() +
	  "  constraints " + oF.Diagram().NumberOfConstraints() + "  runs " + oF.RunCount()
	? "   window " + @@(oF.Window()) + "  marks " + @@(oF.Marks())
	aV = oF.Violations()
	for k = 1 to len(aV)  ? "   ! " + aV[k][:message]  next
	oF.ToPNG("probe_" + cName + ".png")
	return oF
