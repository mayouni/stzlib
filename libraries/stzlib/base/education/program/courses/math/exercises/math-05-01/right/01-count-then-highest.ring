# Set, settle, then count the extrema and keep the highest.
oM = StzMathMotionQ(:Function, [ :f = "{a} * cos(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ] ])
oM.Param("a", 1, 4, 1)
oM.Set("a", 4)
oM.Settle()
aE = oM.Figure().Extrema()
? len(aE)
nTop = aE[1][2]
for i = 2 to len(aE)
	if aE[i][2] > nTop  nTop = aE[i][2]  ok
next
? nTop
