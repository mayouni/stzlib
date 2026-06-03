# Narrative
# --------
# stzString first and last non-space chars
#
# Extracted from stztabletest.ring, block #9.
#ERR Error (R14) : Calling Method without definition: firstnonspacechar

load "../../stzBase.ring"


pr()

o1 = new stzString("   RING  ")

? o1.FirstNonSpaceChar()		#--> R
? o1.FindFirstNonSpaceChar()	#--> 4

? o1.LastNonSpaceChar()		#--> G
? o1.FindLastNonSpaceChar()	#--> 7

pf()
# Executed in 0.02 second(s) in Ring 1.22
