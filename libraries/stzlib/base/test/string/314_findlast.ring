# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #314.

load "../../stzBase.ring"

pr()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindLast("♥♥♥")
#--> 22

? o1.FindLasteAsSection("♥♥♥") 	#NOTE //that the function is misspelled (there is an
#--> [22, 24]			#ERRonous "e" after "Last", but Softanza lets it go!

? o1.FindLastZ("♥♥♥")
#--> [ "♥♥♥", 22 ]

? o1.FindLastZZ("♥♥♥")
#--> [ "♥♥♥", [22, 24] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
