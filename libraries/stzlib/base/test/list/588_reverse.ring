# Narrative
# --------
# Extracted from stzlisttest.ring, block #588.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "tunis", 1:3, 1:3, "gafsa", "tunis", "tunis", 1:3, "gabes", "tunis", "regueb", "regueb" ])

o1.Reverse()
? @@( o1.Content() ) + NL
#--> [ "regueb", "regueb", "tunis", "gabes", [ 1, 2, 3 ], "tunis", "tunis", "gafsa", [ 1, 2, 3 ], [ 1, 2, 3 ], "tunis" ]

? o1.NumberOfDuplicates()
#--> 6

? o1.NumberOfDuplicatesOf("tunis") + NL	# Or NumberOfOccurrence("tunis")
#--> 4

? @@( o1.DuplicatedItems() ) + NL
#--> [ "regueb", "tunis", [ 1, 2, 3 ] ]


? @@( o1.DuplicatesRemoved() )
#--> [ "regueb", "tunis", "gabes", [ 1, 2, 3 ], "gafsa" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.02 second(s) before
