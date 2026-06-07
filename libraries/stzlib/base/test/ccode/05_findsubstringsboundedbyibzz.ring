# Narrative
# --------
# pr()
#
# Extracted from stzccodetest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzString('{ This[@i] = This[@i + 1] + 5 }')
? @@( o1.FindSubStringsBoundedByIBZZ([ "[", "]" ]) )
#--> [ [ 7, 10 ], [ 18, 25 ] ]

? @@( o1.SubStringsBoundedByIB([ "[", "]" ]) )
#--> [ "[@i]", "[@i + 1]" ]

? @@( o1.FindAnySubStringBoundedByZZ([ "[", "]" ]) )
#--> [ [8, 9], [19, 24] ]

? o1.NumbersAfter("@i")
#--> [ "+1", "+5" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.07 second(s) in ring 1.21
# Executed in 0.29 second(s) in ring 1.17
