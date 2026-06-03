# Narrative
# --------
# Navigation to next and previous month
#
# Extracted from stzcalendartest.ring, block #14.

load "../../stzBase.ring"


pr()

oCal = new stzCalendar([2024, 10])
oCal {
	? Current()
	#--> October 2024

	? NextMonth() # Does not move the calendar, just returns the month
	#--> November

	? Current() # Calendar is still in october!
	#--> October 2024

	GotoNextMonth() # Now it will move to next month

	? Current() + NL
	#--> November 2024

	# Let's do the same gymanastics with previous month

	? PreviousMonth()
	#--> October

	? Current()
	#--> November 2024

	GoToPreviousMonth()

	? Current() + NL
	#--> October 2024

}

pf()
# Executed in 0.01 second(s) in Ring 1.24
