# Narrative
# --------
# str = "
#
# Extracted from stzTtexttest.ring, block #16.
#ERR exit 1: Error (S1) In file: 16_str.ring

load "../../stzBase.ring"

pr()

ليكن هذا النّصّ العربّي، هل من قارئ له؟ لا؟! لا بأس: سنحاول...
"

StzTextQ(str) {

	? NumberOfPunctuations() #--> 8
	? Punctuations() #--> [ "،","؟","؟","!",":",".",".","." ]

	? NumberOfUniquePunctuations() #--> 5
	? UniquePunctuations() #--> [ "،","؟","!",":","." ]

	? NumberOfGeneralPunctuations() #--> 0
	? GeneralPunctuations() #--> [ ]

	? NumberOfSupplementalPunctuations() #--> 0
	? SupplementalPunctuations() #--> [ ]

}

pf()
