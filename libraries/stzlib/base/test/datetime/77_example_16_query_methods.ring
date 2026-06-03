# Narrative
# --------
# Example 16: Query methods
#
# Extracted from stzdatetimetest.ring, block #77.

load "../../stzBase.ring"


pr()

oNow = new stzDateTime("")

? oNow.YearsSince(:YearOne)
#--> 2024

? oNow.SecondsSince(:Epoch)
#--> 1759588945

? oNow.DurationSince(:IslamicHijra, :In = :Centuries)
#--> 14

? oNow.SecondsSince(:SpaceAge)
#--> 2153995946021

? oNow.YearsSince(:InternetAge)
#--> 65

? oNow.WeeksSince(:FrenchRevolution)
#--> 12159

? oNow.YearsSince("01/08/1976")
#--> 55

pf()
# Executed in almost 0 second(s) in Ring 1.24
