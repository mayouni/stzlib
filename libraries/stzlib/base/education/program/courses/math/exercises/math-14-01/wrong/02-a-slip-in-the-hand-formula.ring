# A slip in the hand formula: 4x^3 without the minus one gives 4 at 1, and the tape refuses it.
oF = new stzMathFunction("x^4 - x", [ "x" ])
nHand = 4 * 1 * 1 * 1
? nHand
? fabs(nHand - oF.DerivativeAt("x", [ 1 ])) < 0.000001
