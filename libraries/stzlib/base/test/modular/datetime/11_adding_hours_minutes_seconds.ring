# Narrative
# --------
# Adding hours, minutes, seconds
#
# Extracted from stzdatetimetest.ring, block #11.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime {

	AddHours(3)
	? Content()
	#--> 2024-03-15 13:00:00

	AddMinutes(45)
	? Content()
	#--> 2024-03-15 13:45:00

	AddSeconds(30)
	? Content()
	#--> 2024-03-15 13:45:30
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
