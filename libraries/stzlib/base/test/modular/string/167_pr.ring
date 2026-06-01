# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #167.

load "../../../stzBase.ring"


o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")

? @@( o1.SubStringsBoundedBy([ "<<", ">>" ]) )
#--> [ "--hi!--", "--", "hi!" ]

? @@NL( o1.BoundedByZZ([ "<<", ">>" ]) )
#--> [
#	[ "--hi!--", 	[  6, 12 ] ],
#	[ "--", 	[ 20, 21 ] ],
#	[ "hi!", 	[ 29, 31 ] ]
#]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.18
