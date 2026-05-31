# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #10.

load "../../../stzBase.ring"


? Q("ring").IsAQ(:String).InLowercase() 		#--> TRUE
? Q("ring").IsAQ(:String).WhichIs().InLowercase()	#--> TRUE
? Q("ring").IsAQ(:String).Which().IsInLowercase()	#--> TRUE
? Q("ring").IsAQ(:String).Which().IsLowercase()		#--> TRUE

pf()
# Executed in 0.05 second(s) in Ring 1.23
