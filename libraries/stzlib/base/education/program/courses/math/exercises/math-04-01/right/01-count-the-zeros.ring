# The figure, then the zeros it found, counted.
oF = StzMathFigureQ(:Function, [ :f = "x^2 - 4", :on = [ -3, 3 ], :mark = [ :zeros, :extrema ] ])
? oF.Why()
? len( oF.Zeros() )
