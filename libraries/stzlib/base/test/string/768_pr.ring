# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #768.

load "../../stzBase.ring"


o1 = new stzString("eeeeTUNISIAiiiii")

o1 {
	? HasRepeatedLeadingChars()
	#--> TRUE

	? NumberOfRepeatedLeadingChars()
	#--> 4

	? RepeatedLeadingchars()
	#--> [ "e", "e", "e", "e" ]

	? LeadingSubString()+ NL
	#--> "eeee"
	
	? HasRepeatedTrailingChars()
	#--> TRUE

	? NumberOfRepeatedTrailingChars()
	#--> 5

	? RepeatedTrailingChars()
	#--> [ "i", "i", "i", "i", "i" ]

	? TrailingSubString()
	#--> "iiiii"	
}

pf()
# Executed in 0.02 second(s).
