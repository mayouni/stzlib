# The tape's slope, then the hand formula checked against it.
oF = new stzMathFunction("x^4 - x", [ "x" ])
nTape = oF.DerivativeAt("x", [ 1 ])
? nTape
nHand = 4 * 1 * 1 * 1 - 1
? fabs(nHand - nTape) < 0.000001
