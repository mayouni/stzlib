# Narrative
# --------
# Comparing dates
#
# Extracted from stzdatetest.ring, block #20.

load "../../stzBase.ring"


pr()

oDate1 = StzDateQ("15/06/2024")
oDate2 = StzDateQ("20/06/2024")

? oDate1.IsBefore(oDate2)
#--> TRUE

? oDate2.IsAfter(oDate1)
#--> TRUE

? oDate1.IsEqual(oDate2)
#--> FALSE

# Or Better
? ""

? oDate1 < oDate2
#--> TRUE

? oDate1 < "20/06/2024"
#--> TRUE

? ""

? oDate1 > oDate2
#--> FALSE

? oDate1 > "20/06/2024"
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.23
