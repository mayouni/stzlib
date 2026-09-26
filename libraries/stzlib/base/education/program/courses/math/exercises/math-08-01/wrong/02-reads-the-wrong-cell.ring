# Reads row 1, column 1 instead of row 2, column 2.
oP = StzMathFigureQ(:Matrix, [ :product = [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 5, 6 ], [ 7, 8 ] ] ], :show = [ 2, 2 ] ])
? oP.Why()
? oP.Fact(:datum, [ "c1_1", "v" ])[:message]
