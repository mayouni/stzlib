# Counts the fractions whose numerator is larger than 1 -- the wrong question, and the wrong answer.
oC = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 4 ], [ 2, 3 ], [ 5, 8 ], [ 5, 12 ] ] ])
? oC.Why()
aF = [ [ 3, 4 ], [ 2, 3 ], [ 5, 8 ], [ 5, 12 ] ]
nCount = 0
for i = 1 to len(aF)
	if aF[i][1] > 1  nCount++  ok
next
? nCount
