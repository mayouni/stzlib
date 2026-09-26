# One figure of four, then each fraction asked against a half by cross multiplication.
oC = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 4 ], [ 2, 3 ], [ 5, 8 ], [ 5, 12 ] ] ])
? oC.Why()
aF = [ [ 3, 4 ], [ 2, 3 ], [ 5, 8 ], [ 5, 12 ] ]
nCount = 0
for i = 1 to len(aF)
	if aF[i][1] * 2 > aF[i][2]  nCount++  ok
next
? nCount
