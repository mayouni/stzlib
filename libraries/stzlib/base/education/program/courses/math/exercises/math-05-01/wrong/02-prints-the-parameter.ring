# Prints the parameter itself, which is the input, never the picture's answer.
oM = StzMathMotionQ(:Function, [ :f = "{a} * cos(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ] ])
oM.Param("a", 1, 4, 1)
oM.Set("a", 4)
oM.Settle()
? oM.Value("a")
? oM.Value("a")
