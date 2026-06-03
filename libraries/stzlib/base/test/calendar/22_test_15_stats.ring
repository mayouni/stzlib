# Narrative
# --------
# #  Test 15: Stats                          #
#
# Extracted from stzcalendartest.ring, block #22.

load "../../stzBase.ring"

#------------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    ? @@NL(Stats())
}
#-->
'
[
	[ "metric", "value" ],
	[ "Total Days", 31 ],
	[ "Working Days", 23 ],
	[ "Weekend Days", 7 ],
	[ "Holidays", 1 ],
	[ "Total Available Hours", 161 ],
	[ "Average Hours Per Day", 7 ],
	[ "First Working Day", "2024-10-01" ],
	[ "Last Working Day", "2024-10-31" ]
]
'

pf()
# Executed in 0.20 second(s) in Ring 1.24
