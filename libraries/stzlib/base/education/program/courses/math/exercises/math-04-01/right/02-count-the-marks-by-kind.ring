# The same count, read from every mark's kind.
oF = StzMathFigureQ(:Function, [ :f = "x^2 - 4", :on = [ -3, 3 ], :mark = [ :zeros, :extrema ] ])
? oF.Why()
aM = oF.Marks()
nCount = 0
for i = 1 to len(aM)
	if aM[i][1] = "zero"  nCount++  ok
next
? nCount
