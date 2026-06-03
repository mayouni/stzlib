# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #360.
#ERR Error (R14) : Calling Method without definition: findantisectionszz

load "../../stzBase.ring"

pr()

o1 = new stzSplitter(10)
? @@( o1.SplitAroundSections([ [4, 5], [ 8, 8] ]) )
#--> [ [ 1, 3 ], [ 6, 7 ], [ 9, 10 ] ]

? @@( o1.SplitAroundSectionsIB([ [4, 5], [ 8, 8] ]) )

o1 = new stzString("...♥♥..♥..")
#		    1234567890

? @@( o1.SplitAroundSections([ [ 4, 5], [8,8] ]) )
#--> [ "...", "..", ".." ]

? @@( o1.SplitAroundSectionsIB([ [ 4, 5], [8,8] ]) )
#--> [ "...♥", "♥..♥", "♥.." ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
