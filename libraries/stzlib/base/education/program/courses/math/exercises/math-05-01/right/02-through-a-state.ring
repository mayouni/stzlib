# The same, reached through a declared state.
oM = StzMathMotionQ(:Function, [ :f = "{a} * cos(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ] ])
oM.Param("a", 1, 4, 1)
oM.State("a at four", [ [ :Set, "a", 4 ] ])
oM.Apply(1)
aE = oM.Figure().Extrema()
? len(aE)
aY = []
for i = 1 to len(aE)
	aY + aE[i][2]
next
? StzListOfNumbersQ(aY).Max()
