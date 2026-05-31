# Narrative
# --------
# #  DateInfo variations           #
#
# Extracted from stzcalendartest.ring, block #43.

load "../../../stzBase.ring"

#--------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Holiday")
    
    # Test working day
    ? "Working Day Info:"
    ? @@NL(DateInfo("2024-10-03"))
    
    ? nl + "Holiday Info:"
    ? @@NL(DateInfo("2024-10-05"))
    
    ? nl + "Weekend Info:"
    ? @@NL(DateInfo("2024-10-06"))
}
#-->
'
Working Day Info:
[
	[ "date", "2024-10-03" ],
	[ "isWorkingDay", 1 ],
	[ "isHoliday", 0 ],
	[ "availableHours", 7 ]
]

Holiday Info:
[
	[ "date", "2024-10-05" ],
	[ "isWorkingDay", 0 ],
	[ "isHoliday", 1 ],
	[ "availableHours", 0 ]
]

Weekend Info:
[
	[ "date", "2024-10-06" ],
	[ "isWorkingDay", 0 ],
	[ "isHoliday", 0 ],
	[ "availableHours", 0 ]
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.24
