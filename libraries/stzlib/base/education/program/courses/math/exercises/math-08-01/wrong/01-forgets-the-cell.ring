# Declares the product and stops there: the cell was never asked about.
oP = StzMathFigureQ(:Matrix, [ :product = [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 5, 6 ], [ 7, 8 ] ] ], :show = [ 2, 2 ] ])
? oP.Why()
