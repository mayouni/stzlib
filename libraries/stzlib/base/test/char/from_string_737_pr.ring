# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #737.

load "../../stzBase.ring"

pr()

o1 = new stzString("maliNIGERtogoSENEGAL")

? @@NL( o1.Parts2Using('{ StzCharQ(This[@i]).CharCase() }') ) + NL
#--> [ 	
#	"mali" 		= :Lowercase,
# 	"NIGER" 	= :Uppercase,
#	"togo" 		= :Lowercase,
#	"SENEGAL" 	= :Uppercase
#    ]

? @@NL( o1.Parts2UsingZZ('{ StzCharQ(This[@i]).CharCase() }') )
#--> [
#	[ "mali", [ 1, 4 ] ],
#	[ "NIGER", [ 5, 9 ] ],
#	[ "togo", [ 10, 13 ] ],
#	[ "SENEGAL", [ 14, 20 ] ]
# ]

pf()
# Executed in 0.32 second(s).
