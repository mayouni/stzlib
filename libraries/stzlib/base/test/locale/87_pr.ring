# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #87.

load "../../stzBase.ring"


? @@NL( DefaultDaysOfWeek() ) + NL
#-->
'
[
	[ "1", "monday" ],
	[ "2", "tuesday" ],
	[ "3", "wednesday" ],
	[ "4", "thursday" ],
	[ "5", "friday" ],
	[ "6", "saturday" ],
	[ "7", "sunday" ]
]
'

// Testing the nth day of week
o1 = new stzLocale("en_US")

? o1.Country() #--> united_states
? o1.Abbreviation() #--> en_US
? o1.FirstDayOfWeek() + NL #--> sunday

? o1.NthDayOfWeek(1) + NL #--> sunday

? @@( o1.DaysOfWeek() )
#--> [ "sunday", "monday", "tuesady", "wednesday", "thirsday", "friday", "saturday" ]

pf()
# Executed in 0.03 second(s) in Ring 1.23
