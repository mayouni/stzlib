# Narrative
# --------
# Adding and retrieving points
#
# Extracted from stztimelinetest.ring, block #4.

load "../../../stzBase.ring"


pr()

oTimeLine = new stzTimeLine("2024-01-01 00:00:00", "2024-12-31 23:59:59")

oTimeLine {

	AddPoint("NEW_YEAR", "2024-01-01 00:00:00")
	AddPoint("VALENTINE", "2024-02-14 00:00:00")
	AddPoint("summer", "2024-06-21 00:00:00") # Note all labels are uppercased internally

	? CountPoints()
	#--> 3

	? @@( PointNames() )
	#--> ["NEW_YEAR", "VALENTINE", "SUMMER"]

	? Point("VALENTINE")
	#--> 2024-02-14 00:00:00

	? HasPoint("sUMMER") # You can enter lable in any case
	#--> TRUE

	? HasPoint("WINTER")
	#--> FALSE

	? @@NL( Points() )
	#--> [
	# 	[ "NEW_YEAR", "2024-01-01 00:00:00" ],
	# 	[ "VALENTINE", "2024-02-14 00:00:00" ],
	# 	[ "SUMMER", "2024-06-21 00:00:00" ]
	# ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.24
