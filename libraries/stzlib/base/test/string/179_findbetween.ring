# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #179.
#ERR Error (R14) : Calling Method without definition: findbetween

load "../../stzBase.ring"

pr()

o1 = new stzString("...<<hi!>>...<<-->>...<<hi!>>...")

# Finding the substring "hi!" bounded by "<<" and ">>"
? @@( o1.FindBetween("hi!", "<<", ">>") )
#--< [ 6, 25 ]

# Written in a near-natural form:
? @@( o1.FindXT("hi!", :Between = ["<<", ">>"]) )
#--> [ 6, 25 ]

# We can yield not only the positions but the hole sections:
? @@( o1.FindBetweenAsSections("hi!", "<<", ">>") )
#--> [ [ 6, 8 ], [ 25, 27 ] ]

# Written in a near-natural form:
? @@( o1.FindAsSectionsXT("hi!", :Between = ["<<", ">>"]) )
#--> [ [ 6, 8 ], [ 25, 27 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.19
