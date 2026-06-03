# Narrative
# --------
# #  Test 12: Copy and comparison           #
#
# Extracted from stzcalendartest.ring, block #19.

load "../../stzBase.ring"

#-----------------------------------------#

pr()

oCal1 = new stzCalendar([2024, 10])
oCal1.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])

oCal2 = oCal1.Copy()
oCal2.GotoNextMonth()

? "Original: " + oCal1.Current() #--> October 2024
? "Copy: " + oCal2.Current()	 #--> October 2024

? @@NL(oCal1.CompareWith(oCal2))
#-->
'
[
	[
		"Metric",
		"This Calendar",
		"Other Calendar",
		"Difference"
	],
	[
		"Total Days",
		31,
		30,
		1
	],
	[
		"Working Days",
		23,
		21,
		2
	],
	[
		"Available Hours",
		184,
		168,
		16
	],
	[
		"Holidays",
		0,
		0,
		0
	],
	[
		"Total Weeks",
		5,
		5,
		0
	]
]
'

pf()
# Executed in 0.28 second(s) in Ring 1.24
