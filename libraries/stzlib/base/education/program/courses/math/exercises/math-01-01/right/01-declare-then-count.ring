# Declares the line, reads its sentence, then counts by asking each point.
oL = StzMathFigureQ(:NumberLine, [ :on = [ 0, 20 ], :points = [ 4, 11, 17.5 ] ])
? oL.Why()
nCount = 0
aPoints = [ 4, 11, 17.5 ]
for i = 1 to len(aPoints)
	if aPoints[i] > 10  nCount++  ok
next
? nCount
