# Sets a and reads the figure without settling: the marks still belong to a at one.
oM = StzMathMotionQ(:Function, [ :f = "{a} * cos(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ] ])
oM.Param("a", 1, 4, 1)
oM.Settle()
oM.Set("a", 4)
aE = oM.Figure().Extrema()
? len(aE)
? aE[1][2]
