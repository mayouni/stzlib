# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #770.

load "../../../stzBase.ring"


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
