# Declares the figure and stops there: the outliers were never asked for.
aV = [ 3, 7, 7, 8, 9, 10, 11, 30 ]
oB = StzMathFigureQ(:BoxPlot, [ :of = aV ])
? oB.Why()
