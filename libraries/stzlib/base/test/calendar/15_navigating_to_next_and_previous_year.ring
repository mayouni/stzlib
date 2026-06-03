# Narrative
# --------
# Navigating to Next and previous year
#
# Extracted from stzcalendartest.ring, block #15.

load "../../stzBase.ring"


pr()

oCal = new stzCalendar([2024, 10])
oCal {
	? Current()
	#--> October 2024

	? NextYear() # Does not move the calendar, just returns the Year
	#--> 2025

	? Current() # Calendar is still in october!
	#--> October 2024

	GotoNextYear() # Now it will move to next Year

	? Current() + NL
	#--> November 2025

	# Let's do the same gymanastics with previous Year

	? PreviousYear()
	#--> 2024

	? Current()
	#--> November 2025

	GoToPreviousYear()

	? Current() + NL
	#--> October 2024

}


pf()
# Executed in almost 0 second(s) in Ring 1.24
