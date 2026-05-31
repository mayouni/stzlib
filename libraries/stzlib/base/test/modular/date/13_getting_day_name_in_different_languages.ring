# Narrative
# --------
# Getting day name in different languages
#
# Extracted from stzdatetest.ring, block #13.

load "../../../stzBase.ring"


pr()

oDate = StzDateQ("27/09/2025")

? oDate.Day()
#--> Saturday

? oDate.DayIn(:French)
#--> Samedi

? oDate.DayIn(:Arabic)
#o--> السبت

pf()
# Executed in almost 0 second(s) in Ring 1.23
