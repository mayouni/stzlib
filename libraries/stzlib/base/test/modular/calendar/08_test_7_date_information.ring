# Narrative
# --------
# #  Test 7: Date information                #
#
# Extracted from stzcalendartest.ring, block #8.

load "../../../stzBase.ring"

#------------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    ? @@NL(DateInfo("2024-10-03"))
    #-->
	'
	[
		[ "date", "2024-10-03" ],
		[ "isWorkingday", 1 ],
		[ "isholiday", 0 ],
		[ "availablehours", 7 ]
	]
	'

    ? @@NL(RangeInfo("2024-10-01", "2024-10-15"))
    #-->
	'
	[
		[ "startdate", "2024-10-01" ],
		[ "enddate", "2024-10-15" ],
		[ "totaldays", 15 ],
		[ "workingdays", 11 ],
		[ "weekenddays", 4 ],
		[ "holidays", 0 ],
		[ "availablehours", 77 ],
		[ "overlappingevents", [  ] ]
	]
	'

}

pf()
# Executed in 0.05 second(s) in Ring 1.24
