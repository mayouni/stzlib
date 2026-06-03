# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #14.

load "../../stzBase.ring"


 ? QM("ring").IsAQ(:String).
	InLowercaseQ().
	ContainingQ( TheLetter("i") ).
	HavingQ().TheQ().FirstCharQ().EqualToQ("r").
	AndQM().TheQ().Lastchar() = "g"

	#--> TRUE

 ? QM("RING").IsAQ(:String).
	InUppercaseQ().
	ContainingQ( TheLetter("N") ).
	HavingQ().ItsQ().FirstCharQ().EqualToQ("R").
	AndQM().ItsQ().Lastchar() = "G"

	#--> TRUE

 pf()
 # Executed in 0.04 second(s) in Ring 1.23
