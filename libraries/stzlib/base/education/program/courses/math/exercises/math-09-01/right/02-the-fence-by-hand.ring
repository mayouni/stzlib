# The same outlier found by the fence rule, by hand.
aV = [ 3, 7, 7, 8, 9, 10, 11, 30 ]
oB = StzMathFigureQ(:BoxPlot, [ :of = aV ])
? oB.Why()
aS = StzDataSetQ(aV).BoxPlotStats()
nFence = aS[:q3] + 1.5 * aS[:iqr]
aOut = []
for i = 1 to len(aV)
	if aV[i] > nFence  aOut + aV[i]  ok
next
? @@( aOut )
