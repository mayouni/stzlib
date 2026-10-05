# The fit, then the report over it.
aT = [ [ 10, 20, 30 ], [ 15, 25, 35 ], [ 20, 30, 45 ] ]
oT = StzTukeyFitQ(aT)
oT.Polish()
? oT.Common()
? StzTukeyReportQ("table", [ oT ]).IsSound()
