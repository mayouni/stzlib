# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #406.

load "../../stzBase.ring"

pr()

o1 = new stzString("... ____ ... ____")
? o1.Find("...")
#--> [ 1, 10 ]

? @@( o1.FindZZ("...") )
#--> [ [ 1, 3 ], [ 10, 12 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
