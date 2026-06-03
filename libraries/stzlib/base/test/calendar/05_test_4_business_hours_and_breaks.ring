# Narrative
# --------
# #  Test 4: Business hours and breaks      #
#
# Extracted from stzcalendartest.ring, block #5.

load "../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    ? @@NL(BusinessHours())
	#-->
	'
	[
		[ "from", "09:00:00" ],
		[ "to", "17:00:00" ]
	]
	'

    ? @@NL(Breaks())
	#-->
	'
	[
		[ "12:00:00", "13:00:00", "Lunch" ]
	]
	'
}

pf()
# Executed in almost 0 second(s) in Ring 1.26 (Backed by StzEngine)
# Executed in almost 0 second(s) in Ring 1.24
