# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #26.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

? Q(["A", 1, "B", 2, "C", 3 ]) / 3
#--> [ [ "A", 1 ], [ "B", 2 ], [ "C", 3 ] ]

? Q(["A", 1, "B", 2, "C", 3 ]) / Q(3)
#--> A stzList object containg [ [ "A", 1 ], [ "B", 2 ], [ "C", 3 ] ]

# To check it add ( ... ).Content() around it:

? ( Q(["A", 1, "B", 2, "C", 3 ]) / Q(3) ).Content()
# [ [ "A", 1 ], [ "B", 2 ], [ "C", 3 ] ]

pf()
# Executed in 0.05 second(s)
