# Narrative
# --------
# */
#
# Extracted from stzStringTest.ring, block #161.

load "../../../stzBase.ring"

pr()

o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
? @@( o1.FindBetweenAsSections( "hi!", "<<", ">>" ) )
#--> [ [ 8, 10 ], [ 29, 31 ] ]

? @@( o1.FindBetween( "hi!", "<<", ">>" ) )
#--> [ 8, 29 ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.19 second(s) in Ring 1.18
