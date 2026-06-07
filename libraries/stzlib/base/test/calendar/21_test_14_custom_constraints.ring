# Narrative
# --------
# #  Test 14: Custom constraints             #
#
# Extracted from stzcalendartest.ring, block #21.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#------------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    AddConstraint("MaintWindow", [:Every, :Wednesday, :From, "14:00", :To, "16:00"])
    
    ? "Hours on Wednesday 2024-10-09: " + ApplyConstraints("2024-10-09")
    ? @@NL(Constraints())
}
#-->
'
Hours on Wednesday 2024-10-09: 5
[
	[
		"MaintWindow",
		[
			"every",
			"wednesday",
			"from",
			"14:00",
			"to",
			"16:00"
		]
	]
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.24
