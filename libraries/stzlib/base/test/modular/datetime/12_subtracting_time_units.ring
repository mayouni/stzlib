# Narrative
# --------
# Subtracting time units
#
# Extracted from stzdatetimetest.ring, block #12.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime {

	SubtractDays(5)
	? Content()
	#--> 2024-03-10 10:00:00

	SubtractHours(2)
	? Content()
	#--> 2024-03-10 08:00:00

	SubtractMinutes(30)
	? Content()
	#--> 2024-03-10 07:30:00
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
