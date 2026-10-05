# The hand formula compiled as a function of its own, evaluated at 1.
oF = new stzMathFunction("x^4 - x", [ "x" ])
oH = new stzMathFunction("4*x^3 - 1", [ "x" ])
nTape = oF.DerivativeAt("x", [ 1 ])
? nTape
? fabs(oH.ValueAt([ 1 ]) - nTape) < 0.000001
