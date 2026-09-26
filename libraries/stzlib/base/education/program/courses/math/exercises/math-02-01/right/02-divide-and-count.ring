# The same question with the fractions turned into numbers first.
oC = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 4 ], [ 2, 3 ], [ 5, 8 ], [ 5, 12 ] ] ])
? oC.Why()
? StzListOfNumbersQ([ 3/4, 2/3, 5/8, 5/12 ]).NumberOfItemsW('@item > 0.5')
