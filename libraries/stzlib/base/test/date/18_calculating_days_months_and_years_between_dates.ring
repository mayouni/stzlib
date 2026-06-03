# Narrative
# --------
# Calculating days, months and years between dates
#
# Extracted from stzdatetest.ring, block #18.

load "../../stzBase.ring"

pr()

oDate1 = StzDateQ("01/01/2025")
oDate2 = StzDateQ("31/12/2027")

? oDate1.DaysToN(oDate2)
#--> 1094

# Or better:
? oDate2 - oDate1
#--> 1094

? oDate1.MonthsToN(oDate2)
#--> 35

? oDate1.YearsToN(oDate2)
#•--> 2

pf()
# Executed in almost 0 second(s) in Ring 1.23
