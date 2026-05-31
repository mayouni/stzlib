# Narrative
# --------
# Checking if a date is between two other dates
#
# Extracted from stzdatetest.ring, block #19.

load "../../../stzBase.ring"


pr()

oYesterday = new stzDate(:Yesterday)
oToday = new stzDate(:Today)
oTomorrow = new stzDate(:Tomorrow)

? oToday.IsBetween(oYesterday, :And = oTomorrow)
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23
