# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #180.
#ERR Error (R14) : Calling Method without definition: findbetween

load "../../stzBase.ring"

pr()

o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")

# Inside the substrings encolsed between "<<" and ">>", find the
# occurrences of the substring "hi!"

? o1.FindBetween( "hi!", "<<", ">>" )
#--> [8, 29]

# Written in a near-natural form:

? o1.FindXT( "hi!", :Between = ["<<", :And = ">>"] )
#--> [8, 29]

# Yielding the sections not just the positions

? o1.FindBetweenAsSections( "hi!", "<<", ">>" )
#--> [ [8, 10], [29, 31] ]

# Written in a near-natural form:

? o1.FindAsSectionsXT( "hi!", :Between = ["<<", :And = ">>"] )
#--> [ [8, 10], [29, 31] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.34 second(s) in Ring 1.18
