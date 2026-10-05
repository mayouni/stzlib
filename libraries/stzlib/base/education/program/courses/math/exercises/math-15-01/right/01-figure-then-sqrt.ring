# The figure's zero, checked against Ring's square root, and the check refusing 2.2.
oFig = StzMathFigureQ(:Function, [ :f = "x^2 - 5", :on = [ -3, 3 ], :mark = [ :zeros ] ])
aZ = oFig.Zeros()
z = aZ[1][1]
if z < 0  z = aZ[2][1]  ok
? z
? fabs(z - sqrt(5)) < 0.000001
? fabs(2.2 - sqrt(5)) < 0.000001
