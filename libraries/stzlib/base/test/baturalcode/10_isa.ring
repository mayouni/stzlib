# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #10.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"

pr()

? Q("ring").IsAQ(:String).InLowercase() 		#--> TRUE
? Q("ring").IsAQ(:String).WhichIs().InLowercase()	#--> TRUE
? Q("ring").IsAQ(:String).Which().IsInLowercase()	#--> TRUE
? Q("ring").IsAQ(:String).Which().IsLowercase()		#--> TRUE

pf()
# Executed in 0.05 second(s) in Ring 1.23
