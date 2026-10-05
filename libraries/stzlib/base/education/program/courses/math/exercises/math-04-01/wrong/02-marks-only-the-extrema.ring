# Asks for the extrema only, so the figure never looks for a zero.
oF = StzMathFigureQ(:Function, [ :f = "x^2 - 4", :on = [ -3, 3 ], :mark = [ :extrema ] ])
? oF.Why()
? len( oF.Zeros() )
