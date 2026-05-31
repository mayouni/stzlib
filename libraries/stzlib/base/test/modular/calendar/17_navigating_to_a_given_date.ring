# Narrative
# --------
# Navigating to a given date #TODO
#
# Extracted from stzcalendartest.ring, block #17.

load "../../../stzBase.ring"


pr()

oCal = new stzCalendar([2024, 10])
oCal {
	? Current()
	#--> October 2024

	GoTo("01/12/2026") #TODO fix

	? Current()
}

pf()
