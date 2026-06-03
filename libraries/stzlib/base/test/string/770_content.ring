# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #770.
#ERR Error (R14) : Calling Method without definition: removerepeatedleadingcharscs

load "../../stzBase.ring"

pr()

o1 = new stzString("eeeTuniseee")
o1 {
	RemoveRepeatedLeadingChars()
	RemoveRepeatedTrailingChars()
	
	? Content()
	#--> Tunis
}

o1 = new stzString("eeeTuniseee")
o1 {
	RemoveLeadingAndTrailingChars()
	? Content()
	#--> Tunis
}

pf()
# Executed in 0.03 second(s).
