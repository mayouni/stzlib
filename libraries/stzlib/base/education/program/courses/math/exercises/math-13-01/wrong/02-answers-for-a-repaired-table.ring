# Fits a table with the last cell "corrected" to 40: the common value
# agrees, the verdict does not.
aT = [ [ 10, 20, 30 ], [ 15, 25, 35 ], [ 20, 30, 40 ] ]
oT = StzTukeyFitQ(aT)
oT.Polish()
? oT.Common()
? StzTukeyReportQ("table", [ oT ]).IsSound()
