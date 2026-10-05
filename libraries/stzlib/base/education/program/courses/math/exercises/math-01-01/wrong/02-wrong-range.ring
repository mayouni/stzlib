# The right points on the wrong line: 0 to 10 cannot hold 11 and 17.5.
oL = StzMathFigureQ(:NumberLine, [ :on = [ 0, 10 ], :points = [ 4, 11, 17.5 ] ])
? oL.Why()
? 2
