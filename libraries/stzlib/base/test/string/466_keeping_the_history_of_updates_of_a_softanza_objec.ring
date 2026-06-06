# Narrative
# --------
# KEEPING THE HISTORY OF UPDATES OF A SOFTANZA OBJECT
#
# Extracted from stzStringTest.ring, block #466.

load "../../stzBase.ring"


pr()

# Consider this basic string transformation chain in Softanza:

? Q("1 AA 2 B 3 CCC 4 DD 5 Z").
	RemoveWXTQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	Content() + NL
	#--> ABCDZ

# Here, we process the string, removing numbers, spaces,
# and # duplicate characters. The result is clear, but
# the path is forgotten.

# What if we could capture each step of this transformation?
# Say hello the QH() small function:

? @@NL( QH("1 AA 2 B 3 CCC 4 DD 5 Z").
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

pf()
# Executed in 0.44 second(s) in Ring 1.22
