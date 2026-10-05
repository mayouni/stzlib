# The same sentence, with the value computed by hand: 3 times 6 plus 4 times 8.
oP = StzMathFigureQ(:Matrix, [ :product = [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 5, 6 ], [ 7, 8 ] ] ], :show = [ 2, 2 ] ])
? oP.Why()
? "c2_2 carries v = " + (3 * 6 + 4 * 8)
