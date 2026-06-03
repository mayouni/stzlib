# Narrative
# --------
# Adding days to datetime
#
# Extracted from stzdatetimetest.ring, block #9.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime {

	AddDays(5)
	? Content()
	#--> 2024-03-20 10:00:00

	SubtractDays(3)
	? Content()
	#--> 2024-03-17 10:00:00
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
