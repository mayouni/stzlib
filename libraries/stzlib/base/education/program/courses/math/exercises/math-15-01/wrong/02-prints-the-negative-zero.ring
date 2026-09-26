# Prints the negative zero where the positive one was asked.
oFig = StzMathFigureQ(:Function, [ :f = "x^2 - 5", :on = [ -3, 3 ], :mark = [ :zeros ] ])
aZ = oFig.Zeros()
z = aZ[1][1]
if z > 0  z = aZ[2][1]  ok
? z
? fabs(z * z - 5) < 0.000001
? 0
