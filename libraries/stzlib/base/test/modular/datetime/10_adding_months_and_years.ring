# Narrative
# --------
# Adding months and years
#
# Extracted from stzdatetimetest.ring, block #10.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime {

	AddMonths(2)
	? Content()
	#--> 2024-05-15 10:00:00

	AddYears(1)
	? Content()
	#--> 2025-05-15 10:00:00
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
