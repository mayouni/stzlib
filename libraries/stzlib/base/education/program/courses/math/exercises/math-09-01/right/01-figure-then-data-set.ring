# The figure's sentence, then the data set's outliers.
aV = [ 3, 7, 7, 8, 9, 10, 11, 30 ]
oB = StzMathFigureQ(:BoxPlot, [ :of = aV ])
? oB.Why()
? @@( StzDataSetQ(aV).Outliers() )
