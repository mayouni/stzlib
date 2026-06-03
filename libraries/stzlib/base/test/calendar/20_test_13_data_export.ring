# Narrative
# --------
# #  Test 13: Data export                   #
#
# Extracted from stzcalendartest.ring, block #20.

load "../../stzBase.ring"

#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Independence Day")
    SetBusinessHours("09:00:00", "17:00:00")
}

? @@NL(oCal.ToHash())
#-->
'
[
	[ "startdate", "2024-10-01" ],
	[ "enddate", "2024-10-31" ],
	[ "year", 2024 ],
	[ "month", 10 ],
	[ "quarter", "" ],
	[ "totaldays", 31 ],
	[ "workingdays", 23 ],
	[ "availablehours", 184 ],
	[
		"workingdayslist",
		[
			1,
			2,
			3,
			4,
			5
		]
	],
	[
		"holidays",
		[
			[ "2024-10-05", "Independence Day" ]
		]
	],
	[ "breaks", [  ] ],
	[ "businessstart", "09:00:00" ],
	[ "businessend", "17:00:00" ]
]
'

pf()
# Executed in 0.16 second(s) in Ring 1.24
