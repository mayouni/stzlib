# Narrative
# --------
# Complex duration with multiple units
#
# Extracted from stzdatetimetest.ring, block #34.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:30:00.750")
oDateTime {

	? DurationTo("2024-04-20 15:45:30", :In = :Days)
	#--> 36
	
	? DurationTo(StzDateTimeQ("2024-04-20 15:45:30"), :InDays)
	#--> 36

	? DurationTo("2027-04-20", :In = :Years)
	#--> 3

	? DurationTo("2030-10-10", :InWeeks)
	#--> 342

	? DurationTo("2027-04-20", :InYears) # Date only
	#--> 3	
}

pf()
# Executed in 0.02 second(s) in Ring 1.24
