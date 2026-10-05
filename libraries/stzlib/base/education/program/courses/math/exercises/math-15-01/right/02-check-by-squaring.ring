# The same, with the check written as squaring back to five.
oFig = StzMathFigureQ(:Function, [ :f = "x^2 - 5", :on = [ -3, 3 ], :mark = [ :zeros ] ])
aZ = oFig.Zeros()
z = aZ[1][1]
if z < 0  z = aZ[2][1]  ok
? z
? fabs(z * z - 5) < 0.000001
? fabs(2.2 * 2.2 - 5) < 0.000001
