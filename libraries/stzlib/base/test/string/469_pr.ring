# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #469.

load "../../stzBase.ring"


? Q("1 AA 2 B 3 CCC 4 DD 5 Z").
	RemoveWXTQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	Content() + NL
#--> ABCDZ

KeepHistory()

? @@NL( Q("1 AA 2 B 3 CCC 4 DD 5 Z").
	RemoveWXTQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	History() ) + NL

#--> [
#	"1 AA 2 B 3 CCC 4 DD 5 Z",
#	" AA  B  CCC  DD  Z",
#	"AABCCCDDZ",
#	"ABCDZ"
# ]

DontKeepHistory()

? @@( Q("1 AA 2 B 3 CCC 4 DD 5 Z").
	RemoveWXTQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	History() )
#--> [ ]

pf()
# Executed in 0.65 second(s) in Ring 1.22
