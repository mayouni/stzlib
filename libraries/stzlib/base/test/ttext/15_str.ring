# Narrative
# --------
# str = "
#
# Extracted from stzTtexttest.ring, block #15.

load "../../stzBase.ring"

“General Punctuation”! ; This means there is more to know, right?!
Well.. there is a set of supplemental “Punctuation” in Unicode.
"

StzTextQ(str) {

	? NumberOfPunctuations() #--> 12
	? Punctuations() #--> [ "“", "”", "!", ";", ",", "?", "!", ":", "”", "." ]

	? NumberOfUniquePunctuations() #--> 7
	? UniquePunctuations() #--> [ "“", "”", "!", ";", ",", "?", "." ]

	? NumberOfGeneralPunctuations() #--> 4
	? GeneralPunctuations() #--> [ "“", "”", "“", "”" ]

	? NumberOfSupplementalPunctuations() #--> 0
	? SupplementalPunctuations() #--> [ ]

}
