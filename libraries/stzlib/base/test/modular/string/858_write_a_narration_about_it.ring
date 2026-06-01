# Narrative
# --------
# #todo Write a narration about it
#
# Extracted from stzStringTest.ring, block #858.

load "../../../stzBase.ring"


pr()

o1 = new stzString("Приве́т नमस्ते שָׁלוֹם")

? @@( o1.PartsUsingXT( "StzCharQ(@char).Script()" ) ) + NL

? @@NL( o1.Parts2UsingXT( "StzCharQ(@char).Script()" ) ) + NL
#--> [
# 	[ "Приве", "cyrillic" 	],
# 	[ "́", 	   "inherited" 	],
# 	[ "т",     "cyrillic" 	],
# 	[ " ",     "common" 	], 
#	[ "नमस्ते",         "devanagari" ],
# 	[ " ",     "common" 	],
#o 	[ "שָׁלוֹם", "hebrew" 	]
# ]

? @@( o1.PartsWXT('{
	StzCharQ(@char).Script() = :Cyrillic
}') )
#--> [ "Приве", "́", "т", " नमस्ते שָׁלוֹם" ]

pf()
# Executed in 0.45 second(s) in Ring 1.22
# Executed in 0.58 second(s) in Ring 1.20
