# The same verdict through the house gate itself: the fit's findings
# ingested by an stzRuleReport.
aT = [ [ 10, 20, 30 ], [ 15, 25, 35 ], [ 20, 30, 45 ] ]
oT = StzTukeyFitQ(aT)
oT.Polish()
? oT.Common()
oRep = new stzRuleReport("table")
oRep.Ingest(oT.Diagnostics("table"))
? oRep.IsSound()
