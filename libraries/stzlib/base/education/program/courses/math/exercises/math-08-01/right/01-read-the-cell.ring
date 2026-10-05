# The product figure, then the cell read off it.
oP = StzMathFigureQ(:Matrix, [ :product = [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 5, 6 ], [ 7, 8 ] ] ], :show = [ 2, 2 ] ])
? oP.Why()
? oP.Fact(:datum, [ "c2_2", "v" ])[:message]
