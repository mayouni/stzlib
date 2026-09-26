# The same line with named points: a name changes nothing the figure counts.
oL = StzMathFigureQ(:NumberLine, [ :on = [ 0, 20 ], :points = [ [ 4, "four" ], 11, [ 17.5, "far" ] ] ])
? oL.Why()
? StzListOfNumbersQ([ 4, 11, 17.5 ]).NumberOfItemsW('@item > 10')
