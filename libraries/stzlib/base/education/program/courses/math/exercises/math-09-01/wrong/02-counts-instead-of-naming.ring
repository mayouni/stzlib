# Counts the outliers instead of naming them: a number where a list was asked.
aV = [ 3, 7, 7, 8, 9, 10, 11, 30 ]
oB = StzMathFigureQ(:BoxPlot, [ :of = aV ])
? oB.Why()
? len( StzDataSetQ(aV).Outliers() )
